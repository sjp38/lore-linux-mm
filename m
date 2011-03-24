Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id BCB7D8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 12:15:08 -0400 (EDT)
Date: Thu, 24 Mar 2011 17:14:46 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
Message-ID: <20110324161446.GA32068@elte.hu>
References: <alpine.DEB.2.00.1103221635400.4521@tiger>
 <20110324142146.GA11682@elte.hu>
 <20110324160310.GA27127@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110324160310.GA27127@elte.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: torvalds@linux-foundation.org, cl@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Ingo Molnar <mingo@elte.hu> wrote:

> Caused by:
> 
> | 8a5ec0ba42c4919e2d8f4c3138cc8b987fdb0b79 is the first bad commit
> | commit 8a5ec0ba42c4919e2d8f4c3138cc8b987fdb0b79
> | Author: Christoph Lameter <cl@linux.com>
> | Date:   Fri Feb 25 11:38:54 2011 -0600
> |
> |    Lockless (and preemptless) fastpaths for slub
> 
> I'll try to revert these:
> 
>  2fd66c517d5e: slub: Add missing irq restore for the OOM path
>  a24c5a0ea902: slub: Dont define useless label in the !CONFIG_CMPXCHG_LOCAL case
>  8a5ec0ba42c4: Lockless (and preemptless) fastpaths for slub

The combo revert below solves the boot crash.

Thanks,

	Ingo

------------------------------->
