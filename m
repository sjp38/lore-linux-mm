Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id EA02A6B0005
	for <linux-mm@kvack.org>; Wed, 30 May 2018 01:49:30 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id k21-v6so14723267ioj.19
        for <linux-mm@kvack.org>; Tue, 29 May 2018 22:49:30 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id z24-v6si13242621ioc.163.2018.05.29.22.49.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 22:49:30 -0700 (PDT)
Date: Tue, 29 May 2018 22:49:26 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 10/34] iomap: fix the comment describing IOMAP_NOWAIT
Message-ID: <20180530054926.GY30110@magnolia>
References: <20180523144357.18985-1-hch@lst.de>
 <20180523144357.18985-11-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523144357.18985-11-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 23, 2018 at 04:43:33PM +0200, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Looks ok,
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
>  include/linux/iomap.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/iomap.h b/include/linux/iomap.h
> index 8f7095fc514e..13d19b4c29a9 100644
> --- a/include/linux/iomap.h
> +++ b/include/linux/iomap.h
> @@ -59,7 +59,7 @@ struct iomap {
>  #define IOMAP_REPORT		(1 << 2) /* report extent status, e.g. FIEMAP */
>  #define IOMAP_FAULT		(1 << 3) /* mapping for page fault */
>  #define IOMAP_DIRECT		(1 << 4) /* direct I/O */
> -#define IOMAP_NOWAIT		(1 << 5) /* Don't wait for writeback */
> +#define IOMAP_NOWAIT		(1 << 5) /* do not block */
>  
>  struct iomap_ops {
>  	/*
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
