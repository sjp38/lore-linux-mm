Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5D9076B009E
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 12:05:20 -0400 (EDT)
Message-ID: <4A327CB1.6060009@redhat.com>
Date: Fri, 12 Jun 2009 12:05:05 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] HWPOISON: define VM_FAULT_HWPOISON to 0 when	feature
 is disabled
References: <20090611142239.192891591@intel.com> <20090611144430.414445947@intel.com> <20090612112258.GA14123@elte.hu> <20090612125741.GA6140@localhost> <20090612131754.GA32105@elte.hu> <alpine.LFD.2.01.0906120827020.3237@localhost.localdomain> <20090612153501.GA5737@elte.hu>
In-Reply-To: <20090612153501.GA5737@elte.hu>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:

> So i think hwpoison simply does not affect our ability to get log 
> messages out - but it sure allows crappier hardware to be used.
> Am i wrong about that for some reason?

You are :)

A 2-bit memory error can be a temporary failure, eg.
due to a cosmic ray.  If bit errors could be prevented
in hardware, there would be no reason to have ECC at all.

The only reason to stop using that page is because we
do not know for sure whether the error was temporary
or permanent (or dependent on a particular bit pattern).

Userspace needs to be notified that some data disappeared,
if it did - for clean pagecache and swap cache pages, the
kernel can simply take the page away and wait for a page
fault...

The sysadmin needs to know that something happened too,
because the hardware *might* have a problem.

However, a 2-bit error does not imply that the hardware
actually needs to be replaced.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
