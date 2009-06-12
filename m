Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F3E486B005C
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 14:06:29 -0400 (EDT)
Date: Fri, 12 Jun 2009 19:07:32 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 1/5] HWPOISON: define VM_FAULT_HWPOISON to 0 when
 feature is disabled
Message-ID: <20090612190732.3e5b6955@lxorguk.ukuu.org.uk>
In-Reply-To: <20090612161431.GB5680@localhost>
References: <20090611142239.192891591@intel.com>
	<20090611144430.414445947@intel.com>
	<20090612112258.GA14123@elte.hu>
	<20090612125741.GA6140@localhost>
	<20090612131754.GA32105@elte.hu>
	<20090612133352.GC6751@localhost>
	<20090612153620.GB23483@elte.hu>
	<20090612161431.GB5680@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H.
 Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> HWPOISON is a reliability enabling feature - if it enables prevalent
> of crappy hardwares, let's celebrate changing the world~~

HWPOISON is not in the most part a reliability enabling feature. Nothing
of the sort.

The existing behaviour is that your system goes kerblam on such a serious
error. The replacement behaviour is that bits of your machine go kerblam
in unpredictable ways.

In both cases you actually improve your reliability with clustering and
failover.

There are a few special cases its potentially useful - lots of VMs being
one where you have some chance of a controlled failure of a bounded
system. But even in that case I know if I was admin my scripts would read

   if (hwpoison_error)
        migrate_all_guests()
        mail admin
        schedule replacement of the machine

I'm not actually sure teaching hwpoison to handle anything but losing
entire guest OS systems is useful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
