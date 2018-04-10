Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 364136B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 02:26:12 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id b11-v6so8758047pla.19
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 23:26:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z22si1310149pgv.684.2018.04.09.23.26.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Apr 2018 23:26:10 -0700 (PDT)
Date: Tue, 10 Apr 2018 08:26:08 +0200
From: Hannes Reinecke <hare@suse.de>
Subject: Re: [PATCH 3/7] block: sanitize blk_get_request calling conventions
Message-ID: <20180410082608.2cb9a6be@pentland.suse.de>
In-Reply-To: <20180409153916.23901-4-hch@lst.de>
References: <20180409153916.23901-1-hch@lst.de>
	<20180409153916.23901-4-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: axboe@kernel.dk, Bart.VanAssche@wdc.com, willy@infradead.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Mon,  9 Apr 2018 17:39:12 +0200
Christoph Hellwig <hch@lst.de> wrote:

> Switch everyone to blk_get_request_flags, and then rename
> blk_get_request_flags to blk_get_request.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  block/blk-core.c                   | 14 +++-----------
>  block/bsg.c                        |  5 ++---
>  block/scsi_ioctl.c                 |  8 +++-----
>  drivers/block/paride/pd.c          |  2 +-
>  drivers/block/pktcdvd.c            |  2 +-
>  drivers/block/sx8.c                |  2 +-
>  drivers/block/virtio_blk.c         |  2 +-
>  drivers/cdrom/cdrom.c              |  2 +-
>  drivers/ide/ide-atapi.c            |  2 +-
>  drivers/ide/ide-cd.c               |  2 +-
>  drivers/ide/ide-cd_ioctl.c         |  2 +-
>  drivers/ide/ide-devsets.c          |  2 +-
>  drivers/ide/ide-disk.c             |  2 +-
>  drivers/ide/ide-ioctls.c           |  4 ++--
>  drivers/ide/ide-park.c             |  4 ++--
>  drivers/ide/ide-pm.c               |  5 ++---
>  drivers/ide/ide-tape.c             |  2 +-
>  drivers/ide/ide-taskfile.c         |  2 +-
>  drivers/md/dm-mpath.c              |  3 ++-
>  drivers/mmc/core/block.c           | 12 +++++-------
>  drivers/scsi/osd/osd_initiator.c   |  2 +-
>  drivers/scsi/osst.c                |  2 +-
>  drivers/scsi/scsi_error.c          |  2 +-
>  drivers/scsi/scsi_lib.c            |  2 +-
>  drivers/scsi/sg.c                  |  2 +-
>  drivers/scsi/st.c                  |  2 +-
>  drivers/target/target_core_pscsi.c |  3 +--
>  fs/nfsd/blocklayout.c              |  2 +-
>  include/linux/blkdev.h             |  5 +----
>  29 files changed, 42 insertions(+), 59 deletions(-)
> 
Long overdue.

Reviewed-by: Hannes Reinecke <hare@suse.com>

Cheers,

Hannes
