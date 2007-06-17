Date: Sun, 17 Jun 2007 21:07:10 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 0/3] no MAX_ARG_PAGES -v2
Message-ID: <20070617190710.GA20682@elte.hu>
References: <20070613100334.635756997@chello.nl> <20070617183213.GA3892@ucw.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070617183213.GA3892@ucw.cz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Ollie Wild <aaw@google.com>, Andrew Morton <akpm@osdl.org>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

* Pavel Machek <pavel@ucw.cz> wrote:

> Hi!
> 
> > This patch-set aims at removing the current limit on argv+env space 
> > aka. MAX_ARG_PAGES.
> 
> Thanks a lot for solving this properly. I have been upping current 
> limits to some insane ammounts to work around this.

seconded! I have tried the patchset and it works great for me. This 
limitation of Linux has bothered me almost since i started using Linux 
more than a decade ago (i remember having run into it when running a 
script on an overly large directory), and it's perhaps the oldest still 
existing userspace-visible limitations of Linux. It was also a really 
hard nut to crack. Kudos Peter! I really cant wait to see this in 2.6.23
:-)

Acked-by: Ingo Molnar <mingo@elte.hu>

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
