Date: Thu, 24 May 2007 11:55:03 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/2] limit print_fatal_signal() rate (was: [RFC] log out-of-virtual-memory events)
Message-ID: <20070524095503.GA14783@elte.hu>
References: <E1Hp5PV-0001Bn-00@calista.eckenfels.net> <464ED258.2010903@users.sourceforge.net> <20070520203123.5cde3224.akpm@linux-foundation.org> <20070524075835.GC21138@elte.hu> <20070524011551.3d72a6e8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070524011551.3d72a6e8.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: righiandr@users.sourceforge.net, Bernd Eckenfels <ecki@lina.inka.de>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 24 May 2007 09:58:35 +0200 Ingo Molnar <mingo@elte.hu> wrote:
> 
> > 
> > * Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > > Well OK.  But vdso-print-fatal-signals.patch is designated 
> > > not-for-mainline anyway.
> > 
> > btw., why?
> 
> err, because that's what I decided a year ago.  I wonder why ;)
> 
> Perhaps because of the DoS thing, but it has a /proc knob and defaults 
> to off, so it should be OK.

yeah. There's also a boot option. To address the DoS angle, should i 
make it optionally printk_ratelimit() perhaps? (although often the 
messages come in streams and skipping a message can be annoying)

> > It's very, very useful to distro, early-boot-userspace and glibc 
> > development. The only add-on change should be to not print SIGKILL 
> > events. Otherwise it's very much a keeper. Hm?
> 
> <promotes it>

thanks :-)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
