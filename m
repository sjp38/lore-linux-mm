Received: by wr-out-0506.google.com with SMTP id 67so638363wri
        for <linux-mm@kvack.org>; Fri, 20 Jul 2007 04:27:34 -0700 (PDT)
Message-ID: <a781481a0707200427y7a29257fpfa5978c391eb3534@mail.gmail.com>
Date: Fri, 20 Jul 2007 16:57:33 +0530
From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: [RFC 1/4] CONFIG_STABLE: Define it
In-Reply-To: <46A097FE.3000701@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070531002047.702473071@sgi.com>
	 <20070531003012.302019683@sgi.com>
	 <a781481a0707200341o21381742rdb15e6a9dc770d27@mail.gmail.com>
	 <46A097FE.3000701@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Snook <csnook@redhat.com>
Cc: "clameter@sgi.com" <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 7/20/07, Chris Snook <csnook@redhat.com> wrote:
> Satyam Sharma wrote:
> > [ Just cleaning up my inbox, and stumbled across this thread ... ]
> >
> >
> > On 5/31/07, clameter@sgi.com <clameter@sgi.com> wrote:
> >> Introduce CONFIG_STABLE to control checks only useful for development.
> >>
> >> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> >> [...]
> >>  menu "General setup"
> >>
> >> +config STABLE
> >> +       bool "Stable kernel"
> >> +       help
> >> +         If the kernel is configured to be a stable kernel then various
> >> +         checks that are only of interest to kernel development will be
> >> +         omitted.
> >> +
> >
> >
> > "A programmer who uses assertions during testing and turns them off
> > during production is like a sailor who wears a life vest while drilling
> > on shore and takes it off at sea."
> >                                                - Tony Hoare
> >
> >
> > Probably you meant to turn off debug _output_ (and not _checks_)
> > with this config option? But we already have CONFIG_FOO_DEBUG_BAR
> > for those situations ...
>
> There are plenty of validation and debugging features in the kernel that go WAY
> beyond mere assertions, often imposing significant overhead (particularly when
> you scale up) or creating interfaces you'd never use unless you were doing
> kernel development work.  You really do want these features completely removed
> from production kernels.

As for entire such "development/debugging-related features", most (all, really)
should anyway have their own config options.

> The point of this is not to remove one-line WARN_ON and BUG_ON checks (though we
> might remove a few from fast paths), but rather to disable big chunks of
> debugging code that don't implement anything visible to a production workload.

Oh yes, but it's still not clear to me why or how a kernel-wide "CONFIG_STABLE"
or "CONFIG_RELEASE" would help ... what's wrong with finer granularity
"CONFIG_xxx_DEBUG_xxx" kind of knobs?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
