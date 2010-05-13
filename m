Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E5A6E6B022C
	for <linux-mm@kvack.org>; Thu, 13 May 2010 10:40:23 -0400 (EDT)
From: Milton Miller <miltonm@bga.com>
Subject: [PATCH 1/9] mm: add generic adaptive large memory allocation APIs
In-Reply-To: <1273744285-8128-1-git-send-email-xiaosuo@gmail.com>
Date: Thu, 13 May 2010 09:39:36 -0500
Message-ID: <1273761576_4060@mail4.comsite.net>
Sender: owner-linux-mm@kvack.org
To: Changli Gao <xiaosuo@gmail.com>
Cc: akpm@linux-foundation.org, Hoang-Nam Nguyen <hnguyen@de.ibm.com>, Christoph Raisch <raisch@de.ibm.com>, Roland Dreier <rolandd@cisco.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Divy Le Ray <divy@chelsio.com>, "James E.J. Bottomley" <James.Bottomley@suse.de>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger@sun.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-scsi@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org, Eric Dumazet <eric.dumazet@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, 13 May 2010 at 17:51:25 +0800, Changli Gao wrote:

> +static inline void *kvcalloc(size_t n, size_t size)
> +{
> +	return __kvmalloc(n * size, __GFP_ZERO);
> 

This needs multiply overflow checking like kcalloc.

milton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
