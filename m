Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F06A96B024D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 12:34:50 -0400 (EDT)
From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [PATCH] fix return value for mb_cache_shrink_fn when nr_to_scan > 0
Date: Tue, 20 Jul 2010 18:34:46 +0200
References: <4C425273.5000702@gmail.com> <201007192039.06670.agruen@suse.de> <4C45BD34.8030905@redhat.com>
In-Reply-To: <4C45BD34.8030905@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201007201834.46593.agruen@suse.de>
Sender: owner-linux-mm@kvack.org
To: Eric Sandeen <sandeen@redhat.com>, Wang Sheng-Hui <crosslonelyover@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-ext4 <linux-ext4@vger.kernel.org>, kernel-janitors <kernel-janitors@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 20 July 2010 17:13:56 Eric Sandeen wrote:
> I think the logic in the mbcache shrinker is fine.

Indeed yes, I got confused, sorry.

On Sunday 18 July 2010 08:36:59 Wang Sheng-Hui wrote:
> I regenerated the patch. Please check it.

Sheng-Hui, the mb_cache_lru_list list is now accessed without holding 
mb_cache_spinlock.

Thanks,
Andreas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
