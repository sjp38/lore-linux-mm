Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D54786B02A9
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 14:44:03 -0400 (EDT)
From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [PATCH] fix return value for mb_cache_shrink_fn when nr_to_scan > 0
Date: Mon, 19 Jul 2010 20:39:06 +0200
References: <4C425273.5000702@gmail.com> <20100718060106.GA579@infradead.org> <4C42A10B.2080904@gmail.com>
In-Reply-To: <4C42A10B.2080904@gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201007192039.06670.agruen@suse.de>
Sender: owner-linux-mm@kvack.org
To: Wang Sheng-Hui <crosslonelyover@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Eric Sandeen <sandeen@redhat.com>, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-ext4 <linux-ext4@vger.kernel.org>, kernel-janitors <kernel-janitors@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sunday 18 July 2010 08:36:59 Wang Sheng-Hui wrote:
> I regenerated the patch. Please check it.

The logic for calculating how many objects to free is still wrong: 
mb_cache_shrink_fn returns the number of entries scaled by 
sysctl_vfs_cache_pressure / 100.  It should also scale nr_to_scan by the 
inverse of that.  The sysctl_vfs_cache_pressure == 0 case (never scale) may 
require special attention.

See dcache_shrinker() in fs/dcache.c.

Thanks,
Andreas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
