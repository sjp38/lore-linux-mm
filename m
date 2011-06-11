Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CC9FF6B0012
	for <linux-mm@kvack.org>; Sat, 11 Jun 2011 05:45:07 -0400 (EDT)
Received: by wyf19 with SMTP id 19so3077147wyf.14
        for <linux-mm@kvack.org>; Sat, 11 Jun 2011 02:45:02 -0700 (PDT)
Date: Sat, 11 Jun 2011 10:45:00 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning
 instead of failing
Message-ID: <20110611094500.GA2356@debian.cable.virginmedia.net>
References: <20110610004331.13672278.akpm@linux-foundation.org>
 <BANLkTimC8K2_H7ZEu2XYoWdA09-3XxpV7Q@mail.gmail.com>
 <20110610091233.GJ24424@n2100.arm.linux.org.uk>
 <alpine.DEB.2.00.1106101150280.17197@chino.kir.corp.google.com>
 <20110610185858.GN24424@n2100.arm.linux.org.uk>
 <alpine.DEB.2.00.1106101456080.23076@chino.kir.corp.google.com>
 <20110610220748.GO24424@n2100.arm.linux.org.uk>
 <alpine.DEB.2.00.1106101510000.23076@chino.kir.corp.google.com>
 <20110610222020.GP24424@n2100.arm.linux.org.uk>
 <alpine.DEB.2.00.1106101526390.24646@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1106101526390.24646@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, pavel@ucw.cz

On Fri, Jun 10, 2011 at 03:30:35PM -0700, David Rientjes wrote:
> On Fri, 10 Jun 2011, Russell King - ARM Linux wrote:
> > So those platforms which don't have a DMA zone, don't have any problems
> > with DMA, yet want to use the very same driver which does have a problem
> > on ISA hardware have to also put up with a useless notification that
> > their kernel might be broken?
> > 
> > Are you offering to participate on other architectures mailing lists to
> > answer all the resulting queries?
> 
> It all depends on the wording of the "warning", it should make it clear 
> that this is not always an error condition and only affects certain types 
> of hardware which the user may or may not have.

I think people will still be worried when they get a warning. And there
are lots of platforms that don't need ZONE_DMA just because devices can
access the full RAM. As Russell said, same drivers may be used on
platforms that can actually do DMA only to certain areas of memory and
require ZONE_DMA (there are several examples on ARM).

If you want, you can add something like CONFIG_ARCH_HAS_ZONE_DMA across
all the platforms that support ZONE_DMA and only get the warning if
ZONE_DMA is available but not enabled.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
