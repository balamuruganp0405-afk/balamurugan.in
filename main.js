/* ==========================================
   1. PRELOADER (Runs immediately to prevent blocking)
   ========================================== */
(function() {
  const preloader = document.querySelector('.loader-overlay');
  if (preloader) {
    const hideLoader = () => {
      preloader.style.opacity = '0';
      setTimeout(() => {
        preloader.style.display = 'none';
        document.body.classList.add('page-loaded');
      }, 500);
    };

    if (document.readyState === 'interactive' || document.readyState === 'complete') {
      hideLoader();
    } else {
      document.addEventListener('DOMContentLoaded', hideLoader);
    }

    // Fallback: hide loader if loading takes too long
    setTimeout(hideLoader, 2000);
  }
})();

document.addEventListener('DOMContentLoaded', () => {

  /* ==========================================
     2. DARK/LIGHT MODE TOGGLER (Permanently locked to dark mode)
     ========================================== */
  document.documentElement.setAttribute('data-theme', 'dark');

  /* ==========================================
     3. STICKY NAVBAR & ACTIVE NAV LINKS
     ========================================== */
  const navbar = document.querySelector('.navbar');
  const navLinks = document.querySelectorAll('.nav-link');
  const sections = document.querySelectorAll('section[id]');

  // Cache section positions to avoid layout thrashing / forced reflow
  let sectionPositions = [];
  function cacheSectionPositions() {
    sectionPositions = [];
    sections.forEach(current => {
      sectionPositions.push({
        top: current.offsetTop - 120,
        height: current.offsetHeight,
        id: current.getAttribute('id')
      });
    });
  }

  // Calculate positions
  cacheSectionPositions();
  window.addEventListener('resize', cacheSectionPositions);
  window.addEventListener('load', cacheSectionPositions);
  setTimeout(cacheSectionPositions, 1000); // Fallback

  if (navbar) {
    window.addEventListener('scroll', () => {
      // Sticky Class
      if (window.scrollY > 50) {
        navbar.classList.add('scrolled');
      } else {
        navbar.classList.remove('scrolled');
      }

      // Scroll Active Link highlighter using cached geometry to prevent forced reflow
      let scrollY = window.scrollY || window.pageYOffset;
      sectionPositions.forEach(pos => {
        if (scrollY > pos.top && scrollY <= pos.top + pos.height) {
          navLinks.forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('href') === `#${pos.id}` || link.getAttribute('href') === `index.html#${pos.id}`) {
              link.classList.add('active');
            }
          });
        }
      });
    }, { passive: true });
  }

  /* ==========================================
     4. MOBILE NAVIGATION DRAWER
     ========================================== */
  const burger = document.querySelector('.burger');
  const navMenu = document.querySelector('.nav-menu');
  const mobileLinks = document.querySelectorAll('.nav-link');

  if (burger && navMenu) {
    burger.addEventListener('click', () => {
      navMenu.classList.toggle('open');
      burger.classList.toggle('toggle');
    });

    mobileLinks.forEach(link => {
      link.addEventListener('click', () => {
        navMenu.classList.remove('open');
        burger.classList.remove('toggle');
      });
    });
  }

  /* ==========================================
     5. HERO ANIMATED TYPING EFFECT
     ========================================== */
  const typedSpan = document.querySelector('.typed-text');
  if (typedSpan) {
    const toTypeArray = JSON.parse(typedSpan.getAttribute('data-words') || '[]');
    const typingDelay = 100;
    const erasingDelay = 60;
    const newLetterDelay = 2000;
    let charIndex = 0;
    let arrayIndex = 0;

    function type() {
      if (charIndex < toTypeArray[arrayIndex].length) {
        typedSpan.textContent += toTypeArray[arrayIndex].charAt(charIndex);
        charIndex++;
        setTimeout(type, typingDelay);
      } else {
        setTimeout(erase, newLetterDelay);
      }
    }

    function erase() {
      if (charIndex > 0) {
        typedSpan.textContent = toTypeArray[arrayIndex].substring(0, charIndex - 1);
        charIndex--;
        setTimeout(erase, erasingDelay);
      } else {
        arrayIndex++;
        if (arrayIndex >= toTypeArray.length) arrayIndex = 0;
        setTimeout(type, typingDelay + 500);
      }
    }

    if (toTypeArray.length) {
      setTimeout(type, 1000);
    }
  }

  /* ==========================================
     6. SCROLL REVEAL ANIMATIONS
     ========================================== */
  const reveals = document.querySelectorAll('.reveal, .reveal-left, .reveal-right');
  
  if ('IntersectionObserver' in window && reveals.length > 0) {
    const revealObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('active');
          observer.unobserve(entry.target);
        }
      });
    }, {
      threshold: 0.01,
      rootMargin: "0px 0px -50px 0px"
    });

    reveals.forEach(el => revealObserver.observe(el));
  } else {
    // Fallback if observer not supported
    reveals.forEach(el => el.classList.add('active'));
  }

  /* ==========================================
     7. ANIMATED STATS COUNTERS
     ========================================== */
  const counters = document.querySelectorAll('.counter');
  
  if ('IntersectionObserver' in window && counters.length > 0) {
    let countTriggered = false;

    const counterObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting && !countTriggered) {
          countTriggered = true;
          startCounters();
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.5 });

    // Observe the stats section
    const statsSection = document.querySelector('.stats');
    if (statsSection) {
      counterObserver.observe(statsSection);
    }

    function startCounters() {
      counters.forEach(counter => {
        const target = +counter.getAttribute('data-target');
        const duration = 2000; // 2 seconds
        const stepTime = Math.max(Math.floor(duration / target), 15);
        let start = 0;

        const timer = setInterval(() => {
          start += Math.ceil(target / (duration / stepTime));
          if (start >= target) {
            counter.textContent = target;
            clearInterval(timer);
          } else {
            counter.textContent = start;
          }
        }, stepTime);
      });
    }
  } else {
    // Fallback: fill targets immediately
    counters.forEach(counter => {
      counter.textContent = counter.getAttribute('data-target');
    });
  }

  /* ==========================================
     8. ANIMATED SKILL BARS (ABOUT PAGE)
     ========================================== */
  const skillSection = document.querySelector('.skills-grid');
  const skillBars = document.querySelectorAll('.skill-progress-bar');

  if ('IntersectionObserver' in window && skillSection && skillBars.length > 0) {
    const skillObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          skillBars.forEach(bar => {
            const width = bar.getAttribute('data-width');
            bar.style.width = width + '%';
          });
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.2 });

    skillObserver.observe(skillSection);
  } else if (skillBars.length > 0) {
    // Fallback
    skillBars.forEach(bar => {
      bar.style.width = bar.getAttribute('data-width') + '%';
    });
  }

  /* ==========================================
     9. PORTFOLIO TABS FILTER (HOME PAGE)
     ========================================== */
  const filterBtns = document.querySelectorAll('.filter-btn');
  const portfolioCards = document.querySelectorAll('.portfolio-card');

  if (filterBtns.length > 0 && portfolioCards.length > 0) {
    filterBtns.forEach(btn => {
      btn.addEventListener('click', () => {
        // Remove active class from other buttons
        filterBtns.forEach(b => b.classList.remove('active'));
        btn.classList.add('active');

        const filter = btn.getAttribute('data-filter');

        portfolioCards.forEach(card => {
          const category = card.getAttribute('data-category');
          
          if (filter === 'all' || category === filter) {
            card.style.display = 'flex';
            setTimeout(() => {
              card.style.opacity = '1';
              card.style.transform = 'scale(1)';
            }, 50);
          } else {
            card.style.opacity = '0';
            card.style.transform = 'scale(0.8)';
            setTimeout(() => {
              card.style.display = 'none';
            }, 300);
          }
        });
      });
    });
  }

  /* ==========================================
     10. BLOG SEARCH & FILTER (BLOG PAGE)
     ========================================== */
  const blogSearch = document.getElementById('blog-search');
  const blogFilterBtns = document.querySelectorAll('.blog-filter-btn');
  const blogGrid = document.querySelector('.blogs-brief-grid');
  const blogCards = document.querySelectorAll('.blog-card');

  if (blogCards.length > 0) {
    // Automatically sort blog cards in descending date order (newest first)
    if (blogGrid) {
      const cardArray = Array.from(blogCards);
      cardArray.sort((a, b) => {
        const parseCardDate = (el) => {
          const span = el.querySelector('.blog-meta span');
          if (!span) return 0;
          const text = span.textContent.trim();
          const d = Date.parse(text);
          return isNaN(d) ? 0 : d;
        };
        return parseCardDate(b) - parseCardDate(a);
      });
      cardArray.forEach(card => blogGrid.appendChild(card));
    }

    let currentCategory = 'all';
    let searchQuery = '';

    function filterBlogPosts() {
      const allCards = document.querySelectorAll('.blog-card');
      allCards.forEach(card => {
        const category = card.getAttribute('data-category');
        const title = card.querySelector('h3').textContent.toLowerCase();
        const desc = card.querySelector('p').textContent.toLowerCase();
        const matchesCategory = currentCategory === 'all' || category === currentCategory;
        const matchesSearch = title.includes(searchQuery) || desc.includes(searchQuery);

        if (matchesCategory && matchesSearch) {
          card.style.display = 'flex';
          setTimeout(() => {
            card.style.opacity = '1';
            card.style.transform = 'translateY(0) scale(1)';
          }, 50);
        } else {
          card.style.opacity = '0';
          card.style.transform = 'translateY(20px) scale(0.95)';
          setTimeout(() => {
            card.style.display = 'none';
          }, 300);
        }
      });
    }

    if (blogSearch) {
      blogSearch.addEventListener('input', (e) => {
        searchQuery = e.target.value.toLowerCase().trim();
        filterBlogPosts();
      });
    }

    if (blogFilterBtns.length > 0) {
      blogFilterBtns.forEach(btn => {
        btn.addEventListener('click', () => {
          blogFilterBtns.forEach(b => b.classList.remove('active'));
          btn.classList.add('active');
          currentCategory = btn.getAttribute('data-filter');
          filterBlogPosts();
        });
      });
    }
  }

  /* ==========================================
     10B. CLICKABLE BLOG CARDS (SITE-WIDE)
     ========================================== */
  document.addEventListener('click', (e) => {
    const card = e.target.closest('.blog-card');
    if (!card) return;
    if (e.target.closest('a')) return;
    const link = card.querySelector('a.read-more-link');
    if (link && link.href) {
      window.location.href = link.href;
    }
  });

  /* ==========================================
     11. TESTIMONIAL CAROUSEL
     ========================================== */
  const track = document.querySelector('.testimonial-track');
  const slides = document.querySelectorAll('.testimonial-slide');
  const dots = document.querySelectorAll('.dot');
  
  if (track && slides.length > 0 && dots.length > 0) {
    let slideIndex = 0;
    let autoSlideInterval;

    function updateCarousel() {
      const offset = -slideIndex * 100;
      track.style.transform = `translateX(${offset}%)`;
      
      dots.forEach(dot => dot.classList.remove('active'));
      dots[slideIndex].classList.add('active');
    }

    function startAutoSlide() {
      autoSlideInterval = setInterval(() => {
        slideIndex++;
        if (slideIndex >= slides.length) {
          slideIndex = 0;
        }
        updateCarousel();
      }, 5000);
    }

    function stopAutoSlide() {
      clearInterval(autoSlideInterval);
    }

    dots.forEach((dot, index) => {
      dot.addEventListener('click', () => {
        slideIndex = index;
        updateCarousel();
        stopAutoSlide();
        startAutoSlide();
      });
    });

    // Pause on hover
    const carouselWrapper = document.querySelector('.testimonial-carousel');
    if (carouselWrapper) {
      carouselWrapper.addEventListener('mouseenter', stopAutoSlide);
      carouselWrapper.addEventListener('mouseleave', startAutoSlide);
    }

    startAutoSlide();
  }

  /* ==========================================
     12. FAQ ACCORDION
     ========================================== */
  const faqQuestions = document.querySelectorAll('.faq-question');
  
  if (faqQuestions.length > 0) {
    faqQuestions.forEach(question => {
      question.addEventListener('click', () => {
        const item = question.parentNode;
        const answer = item.querySelector('.faq-answer');
        const isActive = item.classList.contains('active');

        // Close other accordions
        document.querySelectorAll('.faq-item').forEach(el => {
          if (el !== item) {
            el.classList.remove('active');
            el.querySelector('.faq-answer').style.maxHeight = null;
          }
        });

        // Toggle self
        if (isActive) {
          item.classList.remove('active');
          answer.style.maxHeight = null;
        } else {
          item.classList.add('active');
          answer.style.maxHeight = answer.scrollHeight + 'px';
        }
      });
    });
  }

  /* ==========================================
     13. BACK TO TOP BUTTON
     ========================================== */
  const backToTopBtn = document.getElementById('back-to-top');

  if (backToTopBtn) {
    window.addEventListener('scroll', () => {
      if (window.scrollY > 400) {
        backToTopBtn.classList.add('show');
      } else {
        backToTopBtn.classList.remove('show');
      }
    });

    backToTopBtn.addEventListener('click', () => {
      window.scrollTo({
        top: 0,
        behavior: 'smooth'
      });
    });
  }

  /* ==========================================
     14. CONTACT FORM SUBMISSION VIA FORMSUBMIT.CO
     ========================================== */
  const contactForm = document.getElementById('contact-form');

  if (contactForm) {
    contactForm.addEventListener('submit', (e) => {
      // Perform validation check
      const nameInput = document.getElementById('form-name');
      const emailInput = document.getElementById('form-email');
      const serviceInput = document.getElementById('form-service');
      const messageInput = document.getElementById('form-message');
      const websiteInput = document.getElementById('form-website');

      const name = nameInput ? nameInput.value.trim() : '';
      const email = emailInput ? emailInput.value.trim() : '';
      const service = serviceInput ? serviceInput.value : '';
      const message = messageInput ? messageInput.value.trim() : '';
      const website = websiteInput ? websiteInput.value.trim() : '';

      if (!name || !email || !service || !message) {
        e.preventDefault();
        alert('Please fill in all required fields.');
        return;
      }

      // Basic email regex
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(email)) {
        e.preventDefault();
        alert('Please enter a valid email address.');
        return;
      }

      // Disable submit button during load to prevent double submissions
      const submitBtn = contactForm.querySelector('button[type="submit"]');
      const originalBtnText = submitBtn ? submitBtn.textContent : 'Submit';
      if (submitBtn) {
        submitBtn.disabled = true;
        submitBtn.textContent = 'Sending Message...';
      }

      // If running locally via file:// protocol where FormSubmit AJAX is disallowed
      if (window.location.protocol === 'file:') {
        e.preventDefault();
        alert('Thank you, ' + name + '! Your consultation request has been received (Local Demo Mode). In live production, this delivers directly to balamuruganp0405@gmail.com.');
        window.location.href = 'thank-you.html';
        return;
      }

      e.preventDefault();

      // Prepare FormSubmit submission data
      const formData = {
        name: name,
        email: email,
        service: service,
        website: website,
        message: message,
        _subject: 'New Website Inquiry | balamurugan.in',
        _template: 'table'
      };

      fetch('https://formsubmit.co/ajax/balamuruganp0405@gmail.com', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify(formData)
      })
      .then(response => {
        if (response.ok) {
          contactForm.reset();
          window.location.href = 'thank-you.html';
        } else {
          // Fallback to native form submission if AJAX is gated
          contactForm.submit();
        }
      })
      .catch(error => {
        // Fallback to native form submission
        contactForm.submit();
      });
    });
  }

  /* ==========================================
     15. NEWSLETTER FORM SUBMISSION VIA FORMSUBMIT.CO
     ========================================== */
  // Handles all footer forms site-wide
  document.addEventListener('submit', (e) => {
    const newsletterForm = e.target.closest('.newsletter-form');
    if (newsletterForm) {
      e.preventDefault();
      const emailInput = newsletterForm.querySelector('input[type="email"]');
      if (emailInput && emailInput.value.trim()) {
        const email = emailInput.value.trim();
        const submitBtn = newsletterForm.querySelector('button');
        const originalBtnText = submitBtn ? submitBtn.textContent : '';

        if (submitBtn) {
          submitBtn.disabled = true;
          submitBtn.textContent = '...';
        }

        if (window.location.protocol === 'file:') {
          alert('Thank you for subscribing to our newsletter! (Local Demo Mode)');
          newsletterForm.reset();
          if (submitBtn) {
            submitBtn.disabled = false;
            submitBtn.textContent = originalBtnText;
          }
          return;
        }

        const formData = {
          email: email,
          type: 'Newsletter Subscription Request'
        };

        fetch('https://formsubmit.co/ajax/balamuruganp0405@gmail.com', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify(formData)
        })
        .then(response => {
          alert('Thank you for subscribing to our newsletter!');
          newsletterForm.reset();
          if (submitBtn) {
            submitBtn.disabled = false;
            submitBtn.textContent = originalBtnText;
          }
        })
        .catch(error => {
          alert('Thank you for subscribing to our newsletter!');
          newsletterForm.reset();
          if (submitBtn) {
            submitBtn.disabled = false;
            submitBtn.textContent = originalBtnText;
          }
        });
      }
    }
  });


  /* ==========================================
     16. INTERACTIVE TABLE OF CONTENTS (TOC) CONTROLLER
     ========================================== */
  document.querySelectorAll('.toc-container').forEach(function(toc) {
    let header = toc.querySelector('.toc-header');
    let title = toc.querySelector('.toc-title');

    // If not already enhanced with header wrapper in HTML
    if (!header && title) {
      const headerDiv = document.createElement('div');
      headerDiv.className = 'toc-header';

      const leftDiv = document.createElement('div');
      leftDiv.className = 'toc-header-left';

      const iconSpan = document.createElement('span');
      iconSpan.className = 'toc-icon-badge';
      iconSpan.innerHTML = '<svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor"><path d="M3 13h2v-2H3v2zm0 4h2v-2H3v2zm0-8h2V7H3v2zm4 4h14v-2H7v2zm0 4h14v-2H7v2zM7 7v2h14V7H7z"/></svg>';

      const badge = document.createElement('span');
      badge.className = 'toc-badge';
      badge.textContent = 'Quick Navigation';

      const toggleBtn = document.createElement('button');
      toggleBtn.type = 'button';
      toggleBtn.className = 'toc-toggle-btn';
      toggleBtn.setAttribute('aria-label', 'Toggle Table of Contents');
      toggleBtn.innerHTML = '<span>Hide</span><svg viewBox="0 0 24 24"><path d="M7.41 8.59L12 13.17l4.59-4.58L18 10l-6 6-6-6 1.41-1.41z"/></svg>';

      title.parentNode.insertBefore(headerDiv, title);
      leftDiv.appendChild(iconSpan);
      leftDiv.appendChild(title);
      leftDiv.appendChild(badge);
      headerDiv.appendChild(leftDiv);
      headerDiv.appendChild(toggleBtn);

      toggleBtn.addEventListener('click', function() {
        toc.classList.toggle('collapsed');
        const span = toggleBtn.querySelector('span');
        if (span) {
          span.textContent = toc.classList.contains('collapsed') ? 'Show' : 'Hide';
        }
      });
    } else if (header) {
      const toggleBtn = header.querySelector('.toc-toggle-btn');
      if (toggleBtn) {
        toggleBtn.addEventListener('click', function() {
          toc.classList.toggle('collapsed');
          const span = toggleBtn.querySelector('span');
          if (span) {
            span.textContent = toc.classList.contains('collapsed') ? 'Show' : 'Hide';
          }
        });
      }
    }
  });
});