Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E84CB6B0089
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 11:28:08 -0400 (EDT)
Date: Fri, 12 Jun 2009 08:28:42 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/5] HWPOISON: define VM_FAULT_HWPOISON to 0 when feature
 is disabled
In-Reply-To: <20090612131754.GA32105@elte.hu>
Message-ID: <alpine.LFD.2.01.0906120827020.3237@localhost.localdomain>
References: <20090611142239.192891591@intel.com> <20090611144430.414445947@intel.com> <20090612112258.GA14123@elte.hu> <20090612125741.GA6140@localhost> <20090612131754.GA32105@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On Fri, 12 Jun 2009, Ingo Molnar wrote:
> 
> This seems like trying to handle a failure mode that cannot be and 
> shouldnt be 'handled' really. If there's an 'already corrupted' page 
> then the box should go down hard and fast, and we should not risk 
> _even more user data corruption_ by trying to 'continue' in the hope 
> of having hit some 'harmless' user process that can be killed ...

No, the box should _not_ go down hard-and-fast. That's the last thing we 
should *ever* do.

We need to log it. Often at a user level (ie we want to make sure it 
actually hits syslog, possibly goes out the network, maybe pops up a 
window, whatever).

Shutting down the machine is the last thing we ever want to do. 

The whole "let's panic" mentality is a disease.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
