Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 519BA6B6DAD
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 02:49:39 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id 89so11958732ple.19
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 23:49:39 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g25si15045857pgm.14.2018.12.03.23.49.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 23:49:38 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB47nGR4115162
	for <linux-mm@kvack.org>; Tue, 4 Dec 2018 02:49:37 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p5k3rngu2-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Dec 2018 02:49:16 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 4 Dec 2018 07:48:54 -0000
Date: Tue, 4 Dec 2018 09:48:49 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH 3/3] mm: add missing declaration of memmap_init in
 linux/mm.h
References: <466ad4ebe5d788e7be6a14fbbcaaa9596bac7141.1543899764.git.dato@net.com.org.es>
 <fccff943020c51f2319b673dd9e5720672e64a6e.1543899764.git.dato@net.com.org.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <fccff943020c51f2319b673dd9e5720672e64a6e.1543899764.git.dato@net.com.org.es>
Message-Id: <20181204074848.GH26700@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Adeodato =?iso-8859-1?Q?Sim=F3?= <dato@net.com.org.es>
Cc: linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On Tue, Dec 04, 2018 at 02:14:24AM -0300, Adeodato Sim� wrote:
> This follows-up commit dfb3ccd00a06 ("mm: make memmap_init a proper
> function"), which changed memmap_init from macro to function.
> 
> Signed-off-by: Adeodato Sim� <dato@net.com.org.es>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
> scripts/checkpatch.pl complained about use of extern for a prototype,
> but I preferred to maintain consistency with surrounding code. -d
> 
>  include/linux/mm.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 3eb3bf7774f1..8597b864dd91 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2268,6 +2268,8 @@ static inline void zero_resv_unavail(void) {}
>  #endif
> 
>  extern void set_dma_reserve(unsigned long new_dma_reserve);
> +extern void memmap_init(unsigned long size, int nid,
> +			unsigned long zone, unsigned long start_pfn);
>  extern void memmap_init_zone(unsigned long, int, unsigned long, unsigned long,
>  		enum memmap_context, struct vmem_altmap *);
>  extern void setup_per_zone_wmarks(void);
> -- 
> 2.19.2
> 

-- 
Sincerely yours,
Mike.
