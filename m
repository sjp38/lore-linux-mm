Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 906DA6B022A
	for <linux-mm@kvack.org>; Thu, 13 May 2010 09:36:57 -0400 (EDT)
Subject: Re: [PATCH 1/9] mm: add generic adaptive large memory allocationAPIs
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1273744285-8128-1-git-send-email-xiaosuo@gmail.com>
	<1273756816.5605.3547.camel@twins>
In-Reply-To: <1273756816.5605.3547.camel@twins>
Message-Id: <201005132236.ADJ57893.FLFFMtOVJHOOSQ@I-love.SAKURA.ne.jp>
Date: Thu, 13 May 2010 22:36:51 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: peterz@infradead.org, xiaosuo@gmail.com
Cc: akpm@linux-foundation.org, hnguyen@de.ibm.com, raisch@de.ibm.com, rolandd@cisco.com, sean.hefty@intel.com, hal.rosenstock@gmail.com, divy@chelsio.com, James.Bottomley@suse.de, tytso@mit.edu, adilger@sun.com, viro@zeniv.linux.org.uk, menage@google.com, lizf@cn.fujitsu.com, linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-scsi@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org, eric.dumazet@gmail.com
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> NAK, I really utterly dislike that inatomic argument. The alloc side
> doesn't function in atomic context either. Please keep the thing
> symmetric in that regards.

Excuse me. kmalloc(GFP_KERNEL) may sleep (and therefore cannot be used in
atomic context). However, kfree() for memory allocated with kmalloc(GFP_KERNEL)
never sleep (and therefore can be used in atomic context).
Why kmalloc() and kfree() are NOT kept symmetric?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
