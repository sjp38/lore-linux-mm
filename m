Received: by wr-out-0506.google.com with SMTP id 67so640644wri
        for <linux-mm@kvack.org>; Fri, 20 Jul 2007 04:40:36 -0700 (PDT)
Message-ID: <a781481a0707200440v48dcf70fv621aec863562880c@mail.gmail.com>
Date: Fri, 20 Jul 2007 17:10:34 +0530
From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: [RFC 1/4] CONFIG_STABLE: Define it
In-Reply-To: <46A09DB2.5040408@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070531002047.702473071@sgi.com>
	 <20070531003012.302019683@sgi.com>
	 <a781481a0707200341o21381742rdb15e6a9dc770d27@mail.gmail.com>
	 <46A097FE.3000701@redhat.com>
	 <a781481a0707200427y7a29257fpfa5978c391eb3534@mail.gmail.com>
	 <46A09DB2.5040408@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Snook <csnook@redhat.com>
Cc: "clameter@sgi.com" <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 7/20/07, Chris Snook <csnook@redhat.com> wrote:
> Satyam Sharma wrote:
> > On 7/20/07, Chris Snook <csnook@redhat.com> wrote:
> >> Satyam Sharma wrote:
> >> > [ Just cleaning up my inbox, and stumbled across this thread ... ]
> >> >
> >> >
> >> > On 5/31/07, clameter@sgi.com <clameter@sgi.com> wrote:
> >> >> Introduce CONFIG_STABLE to control checks only useful for development.
> >> >>
> >> >> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> >> >> [...]
> >> >>  menu "General setup"
> >> >>
> >> >> +config STABLE
> >> >> +       bool "Stable kernel"
> >> >> +       help
> >> >> +         If the kernel is configured to be a stable kernel then
> >> various
> >> >> +         checks that are only of interest to kernel development
> >> will be
> >> >> +         omitted.
> >> >> +
> >> >
> >> >
> >> > "A programmer who uses assertions during testing and turns them off
> >> > during production is like a sailor who wears a life vest while drilling
> >> > on shore and takes it off at sea."
> >> >                                                - Tony Hoare
> >> >
> >> >
> >> > Probably you meant to turn off debug _output_ (and not _checks_)
> >> > with this config option? But we already have CONFIG_FOO_DEBUG_BAR
> >> > for those situations ...
> >>
> >> There are plenty of validation and debugging features in the kernel
> >> that go WAY
> >> beyond mere assertions, often imposing significant overhead
> >> (particularly when
> >> you scale up) or creating interfaces you'd never use unless you were
> >> doing
> >> kernel development work.  You really do want these features completely
> >> removed
> >> from production kernels.
> >
> > As for entire such "development/debugging-related features", most (all,
> > really)
> > should anyway have their own config options.
>
> They do.  With kconfig dependencies, we can ensure that those config options are
> off when CONFIG_STABLE is set.  That way you only have to set one option to
> ensure that all these expensive checks are disabled.

Oh, so you mean use this (the negation of this, actually) as a universal
kconfig dependency of all other such development/debugging related stuff?
Hmm, the name is quite misleading in that case.

Anyway, what surprised me was 4/4 in this patchset. Funny that we wouldn't
want to corrupt memory / trash hard disks / follow invalid pointers on a
developers testbox, but (knowingly) want to do that on a production website
running Google.com's website :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
