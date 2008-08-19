Received: by ti-out-0910.google.com with SMTP id j3so29053tid.8
        for <linux-mm@kvack.org>; Tue, 19 Aug 2008 10:57:53 -0700 (PDT)
Date: Tue, 19 Aug 2008 20:54:40 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: Re: [PATCH 1/5] Revert "kmemtrace: fix printk format warnings"
Message-ID: <20080819175440.GA5435@localhost>
References: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro> <Pine.LNX.4.64.0808191049260.7877@shark.he.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0808191049260.7877@shark.he.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Randy.Dunlap" <rdunlap@xenotime.net>
Cc: penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, cl@linux-foundation.org, mathieu.desnoyers@polymtl.ca, tzanussi@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, Aug 19, 2008 at 10:51:32AM -0700, Randy.Dunlap wrote:
> On Tue, 19 Aug 2008, Eduard - Gabriel Munteanu wrote:
> 
> > This reverts commit 79cf3d5e207243eecb1c4331c569e17700fa08fa.
> > 
> > The reverted commit, while it fixed printk format warnings, it resulted in
> > marker-probe format mismatches. Another approach should be used to fix
> > these warnings.
> 
> Such as what?
> 
> Can marker probes be fixed instead?
> 
> After seeing & fixing lots of various warnings in the last few days,
> I'm thinking that people don't look at/heed warnings nowadays.  Sad.
> Maybe there are just so many that they are lost in the noise.

Hi,

Check the next patch in the series, it provides the alternate fix.
I favor this approach more because it involves fewer changes and we
don't have to use things like "%zu" (which make data type size less
apparent).


	Cheers,
	Eduard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
