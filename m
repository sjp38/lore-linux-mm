Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4C2786B0008
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 05:51:22 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x24-v6so10066228edm.13
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 02:51:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ch24-v6si2140ejb.81.2018.10.01.02.51.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 02:51:21 -0700 (PDT)
Date: Mon, 1 Oct 2018 11:51:19 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm/filemap.c: Use vmf_error()
Message-ID: <20181001095119.GE3913@quack2.suse.cz>
References: <20180927171411.GA23331@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180927171411.GA23331@jordon-HP-15-Notebook-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: willy@infradead.org, akpm@linux-foundation.org, jack@suse.cz, mgorman@techsingularity.net, ak@linux.intel.com, jlayton@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 27-09-18 22:44:12, Souptick Joarder wrote:
> These codes can be replaced with new inline vmf_error().
> 
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/filemap.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 52517f2..7d04d7c 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2581,9 +2581,7 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
>  	 * system is low on memory, or a problem occurs while trying
>  	 * to schedule I/O.
>  	 */
> -	if (error == -ENOMEM)
> -		return VM_FAULT_OOM;
> -	return VM_FAULT_SIGBUS;
> +	return vmf_error(error);
>  
>  page_not_uptodate:
>  	/*
> -- 
> 1.9.1
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
