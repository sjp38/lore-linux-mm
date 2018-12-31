Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8E5158E005B
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 01:28:39 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id 41so33478502qto.17
        for <linux-mm@kvack.org>; Sun, 30 Dec 2018 22:28:39 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g5si6960711qtj.167.2018.12.30.22.28.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Dec 2018 22:28:38 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBV6IwaL125676
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 01:28:37 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pqbrw3sa9-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 01:28:37 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 31 Dec 2018 06:28:36 -0000
Date: Mon, 31 Dec 2018 08:28:29 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH] include/linux/gfp.h: fix typo
References: <20181227232354.64562-1-ksspiers@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181227232354.64562-1-ksspiers@google.com>
Message-Id: <20181231062828.GA20219@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyle Spiers <ksspiers@google.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 27, 2018 at 03:23:54PM -0800, Kyle Spiers wrote:
> Fix misspelled "satisfied"
> 
> Signed-off-by: Kyle Spiers <ksspiers@google.com>

Acked-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  include/linux/gfp.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 0705164f928c..5f5e25fd6149 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -81,7 +81,7 @@ struct vm_area_struct;
>   *
>   * %__GFP_HARDWALL enforces the cpuset memory allocation policy.
>   *
> - * %__GFP_THISNODE forces the allocation to be satisified from the requested
> + * %__GFP_THISNODE forces the allocation to be satisfied from the requested
>   * node with no fallbacks or placement policy enforcements.
>   *
>   * %__GFP_ACCOUNT causes the allocation to be accounted to kmemcg.
> -- 
> 2.20.1.415.g653613c723-goog
> 
> 

-- 
Sincerely yours,
Mike.
