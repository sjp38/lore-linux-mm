Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C6F756B005D
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 15:43:24 -0400 (EDT)
Date: Tue, 16 Jun 2009 14:44:30 -0500
From: Russ Anderson <rja@sgi.com>
Subject: Re: [PATCH 00/22] HWPOISON: Intro (v5)
Message-ID: <20090616194430.GA9545@sgi.com>
Reply-To: Russ Anderson <rja@sgi.com>
References: <20090615024520.786814520@intel.com> <4A35BD7A.9070208@linux.vnet.ibm.com> <20090615042753.GA20788@localhost> <Pine.LNX.4.64.0906151341160.25162@sister.anvils> <20090615140019.4e405d37@lxorguk.ukuu.org.uk> <20090615132934.GE31969@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090615132934.GE31969@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Wu Fengguang <fengguang.wu@intel.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, rja@sgi.com
List-ID: <linux-mm.kvack.org>

On Mon, Jun 15, 2009 at 03:29:34PM +0200, Andi Kleen wrote:
> 
> I think you're wrong about killing processes decreasing
> reliability. Traditionally we always tried to keep things running if possible
> instead of panicing.

Customers love the ia64 feature of killing a user process instead of
panicing the system when a user process hits a memory uncorrectable
error.  Avoiding a system panic is a very good thing.


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
