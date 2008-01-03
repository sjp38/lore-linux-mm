From: Andi Kleen <ak@suse.de>
Subject: Re: [patch] mm: fix PageUptodate memory ordering bug
Date: Thu, 3 Jan 2008 14:08:07 +0100
References: <20071218012632.GA23110@wotan.suse.de> <200801022201.28025.ak@suse.de> <20080103033245.GA26487@wotan.suse.de>
In-Reply-To: <20080103033245.GA26487@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200801031408.08194.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

> Hmm, but I did want to allow it to be overridden via maxcpus= command line (or
> hotplug I guess, I hadn't thought of the hotplug case but it allows runtime
> override).

In theory some user space could be set up to always boot with maxcpus=1 and then
only hotplug CPUs later (e.g. might make sense to get faster initial booting on systems
with a lot of CPUs) 

It would be better to use a separate option for such workarounds.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
