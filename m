Date: Thu, 28 Aug 2003 09:02:40 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-test4-mm2
Message-Id: <20030828090240.2cccf4d9.akpm@osdl.org>
In-Reply-To: <1062075227.422.2.camel@lorien>
References: <20030826221053.25aaa78f.akpm@osdl.org>
	<1062075227.422.2.camel@lorien>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Luiz Capitulino <lcapitulino@prefeitura.sp.gov.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Luiz Capitulino <lcapitulino@prefeitura.sp.gov.br> wrote:
>
> when using the hdparm program, thus:
> 
>  # hdparm /dev/hda
> 
>  I'm getting this:
> 
>  Oops: 0000 [#1]

This should fix it.

--- 25/include/linux/genhd.h~large-dev_t-12-fix	2003-08-27 10:36:32.000000000 -0700
+++ 25-akpm/include/linux/genhd.h	2003-08-27 10:36:32.000000000 -0700
@@ -197,7 +197,7 @@ extern void rand_initialize_disk(struct 
 
 static inline sector_t get_start_sect(struct block_device *bdev)
 {
-	return bdev->bd_part->start_sect;
+	return bdev->bd_contains == bdev ? 0 : bdev->bd_part->start_sect;
 }
 static inline sector_t get_capacity(struct gendisk *disk)
 {

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
