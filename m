Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EE7EB6B01E3
	for <linux-mm@kvack.org>; Sun, 16 May 2010 21:34:35 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4H1YXNw006416
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 17 May 2010 10:34:33 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 105F545DE54
	for <linux-mm@kvack.org>; Mon, 17 May 2010 10:34:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E2E1545DE53
	for <linux-mm@kvack.org>; Mon, 17 May 2010 10:34:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A5EAB1DB8055
	for <linux-mm@kvack.org>; Mon, 17 May 2010 10:34:32 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E2B0B1DB8048
	for <linux-mm@kvack.org>; Mon, 17 May 2010 10:34:31 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/9] mm: add generic adaptive large memory allocationAPIs
In-Reply-To: <201005132236.ADJ57893.FLFFMtOVJHOOSQ@I-love.SAKURA.ne.jp>
References: <1273756816.5605.3547.camel@twins> <201005132236.ADJ57893.FLFFMtOVJHOOSQ@I-love.SAKURA.ne.jp>
Message-Id: <20100517103050.21B6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 17 May 2010 10:34:30 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: kosaki.motohiro@jp.fujitsu.com, peterz@infradead.org, xiaosuo@gmail.com, akpm@linux-foundation.org, hnguyen@de.ibm.com, raisch@de.ibm.com, rolandd@cisco.com, sean.hefty@intel.com, hal.rosenstock@gmail.com, divy@chelsio.com, James.Bottomley@suse.de, tytso@mit.edu, adilger@sun.com, viro@zeniv.linux.org.uk, menage@google.com, lizf@cn.fujitsu.com, linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-scsi@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org, eric.dumazet@gmail.com
List-ID: <linux-mm.kvack.org>

> Peter Zijlstra wrote:
> > NAK, I really utterly dislike that inatomic argument. The alloc side
> > doesn't function in atomic context either. Please keep the thing
> > symmetric in that regards.
> 
> Excuse me. kmalloc(GFP_KERNEL) may sleep (and therefore cannot be used in
> atomic context). However, kfree() for memory allocated with kmalloc(GFP_KERNEL)
> never sleep (and therefore can be used in atomic context).
> Why kmalloc() and kfree() are NOT kept symmetric?

In kmalloc case, we need to consider both kmalloc(GFP_KERNEL)/kfree() pair and
kmalloc(GFP_ATOMIC)/kfree() pair. latter is mainly used on atomic context.
To make kfree() atomic help to keep the implementation simple.

But kvmalloc don't have GFP_ATOMIC feautre. that's big difference.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
