Received: by gxk8 with SMTP id 8so6265181gxk.14
        for <linux-mm@kvack.org>; Tue, 19 Aug 2008 14:40:31 -0700 (PDT)
Date: Wed, 20 Aug 2008 00:37:08 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: Re: [PATCH 1/5] Revert "kmemtrace: fix printk format warnings"
Message-ID: <20080819213708.GA5861@localhost>
References: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro> <Pine.LNX.4.64.0808191049260.7877@shark.he.net> <20080819175440.GA5435@localhost> <Pine.LNX.4.64.0808191229330.7877@shark.he.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0808191229330.7877@shark.he.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Randy.Dunlap" <rdunlap@xenotime.net>
Cc: penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, cl@linux-foundation.org, mathieu.desnoyers@polymtl.ca, tzanussi@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, Aug 19, 2008 at 12:32:14PM -0700, Randy.Dunlap wrote:
> > > 
> > > Such as what?
> > > 
> > > Can marker probes be fixed instead?
> 
> Did you answer this?

Yes, they can be fixed, but the probe functions will likely show
warnings unless the way we parse vargs is fixed as well.

> > > After seeing & fixing lots of various warnings in the last few days,
> > > I'm thinking that people don't look at/heed warnings nowadays.  Sad.
> > > Maybe there are just so many that they are lost in the noise.
> > 
> > Hi,
> > 
> > Check the next patch in the series, it provides the alternate fix.
> 
> Yep, I saw that later.
> 
> > I favor this approach more because it involves fewer changes and we
> > don't have to use things like "%zu" (which make data type size less
> > apparent).
> 
> %zu is regular C language.  I.e., I don't get the data type not being
> apparent issue...

Yes, I know. But I feel like using unsigned long is consistent with the
way we handle the call site pointers and gfp_t. Pointers are cast to
unsigned long (in _RET_IP_) and size_t's actual range and size is more
apparent if it's cast to unsigned long as well (since allocation sizes
should scale the same as pointers do, and we know sizeof(unsigned long)
== sizeof(void *) on GCC).

> Maybe kmemtrace should just make everything be long long... :(

I was merely trying to sort this out faster and more consistent.

> -- 
> ~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
