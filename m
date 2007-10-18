Date: Thu, 18 Oct 2007 16:20:06 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH] Fix a build error when BLOCK=n
Message-ID: <20071018142006.GR5063@kernel.dk>
References: <1192716363-31661-1-git-send-email-Emilian.Medve@Freescale.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1192716363-31661-1-git-send-email-Emilian.Medve@Freescale.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Emil Medve <Emilian.Medve@Freescale.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 18 2007, Emil Medve wrote:
> mm/filemap.c: In function '__filemap_fdatawrite_range':
> mm/filemap.c:200: error: implicit declaration of function 'mapping_cap_writeback_dirty'
> 
> This happens when we don't use/have any block devices and a NFS root filesystem
> is used
> 
> mapping_cap_writeback_dirty() is defined in linux/backing-dev.h which used to be
> provided in mm/filemap.c by linux/blkdev.h until commit
> f5ff8422bbdd59f8c1f699df248e1b7a11073027
> 
> Signed-off-by: Emil Medve <Emilian.Medve@Freescale.com>
> ---
> 
> Also removed some trailing whitespaces

Don't include the whitespace cleanup with this change, send it
seperately. For the include fix:

Acked-by: Jens Axboe <jens.axboe@oracle.com>


-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
