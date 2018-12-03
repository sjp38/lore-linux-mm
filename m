Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5A8A66B6A4E
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 12:46:56 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c34so4558373edb.8
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 09:46:56 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 29-v6si2580234ejk.274.2018.12.03.09.46.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 09:46:54 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB3HibHm001151
	for <linux-mm@kvack.org>; Mon, 3 Dec 2018 12:46:53 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p588nu5rh-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 03 Dec 2018 12:46:52 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 3 Dec 2018 17:46:50 -0000
Date: Mon, 3 Dec 2018 19:46:43 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH v2] memblock: Anonotate memblock_is_reserved() with
 __init_memblock.
References: <BLUPR13MB02893411BF12EACB61888E80DFAE0@BLUPR13MB0289.namprd13.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BLUPR13MB02893411BF12EACB61888E80DFAE0@BLUPR13MB0289.namprd13.prod.outlook.com>
Message-Id: <20181203174642.GD26700@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yueyi Li <liyueyi@live.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Dec 03, 2018 at 04:00:08AM +0000, Yueyi Li wrote:
> Found warning:
> 
> WARNING: EXPORT symbol "gsi_write_channel_scratch" [vmlinux] version generation failed, symbol will not be versioned.
> WARNING: vmlinux.o(.text+0x1e0a0): Section mismatch in reference from the function valid_phys_addr_range() to the function .init.text:memblock_is_reserved()
> The function valid_phys_addr_range() references
> the function __init memblock_is_reserved().
> This is often because valid_phys_addr_range lacks a __init
> annotation or the annotation of memblock_is_reserved is wrong.
> 
> Use __init_memblock instead of __init.
> 
> Signed-off-by: liyueyi <liyueyi@live.com>

Acked-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
> 
>  Changes v2: correct typo in 'warning'.
> 
>  mm/memblock.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 9a2d5ae..81ae63c 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1727,7 +1727,7 @@ static int __init_memblock memblock_search(struct memblock_type *type, phys_addr
>  	return -1;
>  }
>  
> -bool __init memblock_is_reserved(phys_addr_t addr)
> +bool __init_memblock memblock_is_reserved(phys_addr_t addr)
>  {
>  	return memblock_search(&memblock.reserved, addr) != -1;
>  }
> -- 
> 2.7.4
> 

-- 
Sincerely yours,
Mike.
