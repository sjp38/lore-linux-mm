Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw01.freescale.net (8.12.11/az33egw01) with ESMTP id l9NJRRns029908
	for <linux-mm@kvack.org>; Tue, 23 Oct 2007 12:27:27 -0700 (MST)
Received: from az33exm24.fsl.freescale.net (az33exm24.am.freescale.net [10.64.32.14])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id l9NJRQdl016644
	for <linux-mm@kvack.org>; Tue, 23 Oct 2007 14:27:27 -0500 (CDT)
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Subject: RE: [PATCH v2] Fix a build error when BLOCK=n
Date: Tue, 23 Oct 2007 12:27:26 -0700
Message-ID: <598D5675D34BE349929AF5EDE9B03E27016E5644@az33exm24.fsl.freescale.net>
In-Reply-To: <20071018152645.GC10674@kernel.dk>
References: <1192719329-32066-1-git-send-email-Emilian.Medve@Freescale.com> <20071018152645.GC10674@kernel.dk>
From: "Medve Emilian-EMMEDVE1" <Emilian.Medve@freescale.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <jens.axboe@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hello Jens,


In who's tree would this go?


Thanks,
Emil.


> -----Original Message-----
> From: Jens Axboe [mailto:jens.axboe@oracle.com] 
> Sent: Thursday, October 18, 2007 10:27 AM
> To: Medve Emilian-EMMEDVE1
> Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org; 
> torvalds@linux-foundation.org
> Subject: Re: [PATCH v2] Fix a build error when BLOCK=n
> 
> On Thu, Oct 18 2007, Emil Medve wrote:
> > mm/filemap.c: In function '__filemap_fdatawrite_range':
> > mm/filemap.c:200: error: implicit declaration of function 
> 'mapping_cap_writeback_dirty'
> > 
> > This happens when we don't use/have any block devices and a 
> NFS root filesystem
> > is used
> > 
> > mapping_cap_writeback_dirty() is defined in 
> linux/backing-dev.h which used to be
> > provided in mm/filemap.c by linux/blkdev.h until commit
> > f5ff8422bbdd59f8c1f699df248e1b7a11073027
> > 
> > Signed-off-by: Emil Medve <Emilian.Medve@Freescale.com>
> 
> Acked-by: Jens Axboe <jens.axboe@oracle.com>
> 
> -- 
> Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
