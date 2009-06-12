Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0A8C46B009A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 11:44:10 -0400 (EDT)
Date: Fri, 12 Jun 2009 17:45:25 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/5] HWPOISON: define VM_FAULT_HWPOISON to 0 when
	feature is disabled
Message-ID: <20090612154525.GA14438@elte.hu>
References: <20090611142239.192891591@intel.com> <20090611144430.414445947@intel.com> <20090612112258.GA14123@elte.hu> <20090612125741.GA6140@localhost> <20090612131754.GA32105@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090612131754.GA32105@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> So i find the whole feature rather dubious - what's the point? We 
> should panic at this point - we just corrupted user data so that 
> piece of hardware cannot be trusted. Nor can any subsequent kernel 
> bug messages be trusted.

s/panic/print nasty message

Not sure what i was smoking there. Sysadmin will panic from a memory 
corruption message anyway.

What feels wrong to me is: kill a process and - in the case where 
that process is restartable or expendable - suggest to the admin 
that "everything is fine, we handled it just fine".

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
