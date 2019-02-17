Return-Path: <SRS0=1HZa=QY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54122C43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 08:28:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC71C2195D
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 08:28:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC71C2195D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D4088E0003; Sun, 17 Feb 2019 03:28:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 882728E0001; Sun, 17 Feb 2019 03:28:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 749B98E0003; Sun, 17 Feb 2019 03:28:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3441B8E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 03:28:28 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id q20so10272135pls.4
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 00:28:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=p/ibebietbEVsnIK6Cv21nrDd0JTZGwZt4XvdnJH8B0=;
        b=RGk4/fszIjQJwuXJCb6xjH+k5dx/Qy+EfHTaWryqbk83GdvZxwZsbfqOzWdehT+GXG
         QpZ25XG3dh47SH59cVc3MmuT7B2ZrBB+YYDg5kIUsl1ZoL7kvHv2ReYdr+NQI9Uszr1K
         Sv8YInPap5le/R4bx/8IoeDzIbe0t2jRS24Za9eefESxbr7jpjAB1U33ujyNQxfLuZcD
         G3CU/kkL6OkKlJEJh0QR8oPcYg/NyqPJLWrACwS2+U1rtOO8Wfk7/c4aEiKUK9zdBvY+
         kF4a9LiXjAjuekiG17KOzE+rUNrKkInVMzrikM2aQmSwWHB64WMsuprSgnzTX1HPZ0ke
         K2wg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuaObYn4VVG6GjuF3tsKNIFb2qz9DzQ7vbbpHV/ZbxxlqDspo4KR
	OaGCrfgglurq7YsqDmkqCvYUCaYQc3gh6GBIxxjnkRGg2JCdUaiKov5nLystIMW0CIV/H9jsa1m
	tYMaYxc0zajTySO7de9q9MgaN+6g6/LKMCc/0M/lw5MSt/9XtkAtoxZsQyChgBPrUpQ==
X-Received: by 2002:a17:902:3f81:: with SMTP id a1mr19075899pld.258.1550392107862;
        Sun, 17 Feb 2019 00:28:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaEkQQq80jLKle3/npHpbPrQwG/dEF0v+t3EFgIgfrorpH+wa2r/5WFfCl3iK6AXkgYDiD4
X-Received: by 2002:a17:902:3f81:: with SMTP id a1mr19075868pld.258.1550392107150;
        Sun, 17 Feb 2019 00:28:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550392107; cv=none;
        d=google.com; s=arc-20160816;
        b=OpPLg4Nabfao2l80UuwjsjDKmkj7n0PQQ2PIUIh4Q6c+LASrfSMm+QMnwNHPfqUaPe
         h0p1qwNXXivJrx8MgE49KpEOisn/utQ8jGPF28bBQUGqTuLpLvFwPEJHJi6hvTRu7Pkg
         Pjo0zFh/wZEyaMIxpH2W8VCca6eB5oZNYdlJtTyaOp8spg5Usj/RlKiPJ+j+Xa/tS16j
         gPsB/11M5GcBwis5v0dwntPQmDPIQ5YaTLhBqDv4/McDY/uzYmCxuaNqqFrTJZvqydhC
         0if4EiVmHKzyJmUHXmhqDM3PRA2lNX3B4CntpPe2AnRA3rj/X+1SmvCE6dHVYGTsfPmf
         5J0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=p/ibebietbEVsnIK6Cv21nrDd0JTZGwZt4XvdnJH8B0=;
        b=KK7TrasaV3/v/mnlMrCQ13FDfkzkXFRnthFxg1ZOBn7mNMCKyERFp44jICTKiIhVZx
         qvQF8vMoc6L4ObwuV6v7wNYCD8/Y5X3RKamtdGAOdJcP20yIaPh5vjqMLM48NPKe2+Qp
         xNJddJmqdaG0Jq5HWaWfu2JlcBIaoeRbfShSzSldAlXv+lrFf7sxn5ORAUA7TSNz8c/A
         ldgPbh7ll0Qn8U66ylK0JG6HDljYBVPNbWVIQMG5A9QNAiJClX7mDuASVSqMfVgt5rvQ
         ho7/9PG5AFGCIWKJSt/FqIhDhEhIFIYG4qhZWQUMbGi3gJjdSDjQnBm3/MDvFrY6QEA0
         NdBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v7si9794312pga.15.2019.02.17.00.28.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Feb 2019 00:28:27 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1H8ISYi060624
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 03:28:26 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qq0uyn45f-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 03:28:26 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 17 Feb 2019 08:28:24 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sun, 17 Feb 2019 08:28:20 -0000
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1H8SJpa22282338
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Sun, 17 Feb 2019 08:28:19 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6BB7E42042;
	Sun, 17 Feb 2019 08:28:19 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 04F0042041;
	Sun, 17 Feb 2019 08:28:19 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Sun, 17 Feb 2019 08:28:18 +0000 (GMT)
Date: Sun, 17 Feb 2019 10:28:17 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: "David S. Miller" <davem@davemloft.net>
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] sparc64: simplify reduce_memory() function
References: <1549963956-28269-1-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1549963956-28269-1-git-send-email-rppt@linux.ibm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19021708-0008-0000-0000-000002C160E7
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021708-0009-0000-0000-0000222D8BC1
Message-Id: <20190217082816.GB1176@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-17_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=881 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902170066
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Any comments on this?

On Tue, Feb 12, 2019 at 11:32:36AM +0200, Mike Rapoport wrote:
> The reduce_memory() function clampls the available memory to a limit
> defined by the "mem=" command line parameter. It takes into account the
> amount of already reserved memory and excludes it from the limit
> calculations.
> 
> Rather than traverse memblocks and remove them by hand, use
> memblock_reserved_size() to account the reserved memory and
> memblock_enforce_memory_limit() to clamp the available memory.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  arch/sparc/mm/init_64.c | 42 ++----------------------------------------
>  1 file changed, 2 insertions(+), 40 deletions(-)
> 
> diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
> index b4221d3..478b818 100644
> --- a/arch/sparc/mm/init_64.c
> +++ b/arch/sparc/mm/init_64.c
> @@ -2261,19 +2261,6 @@ static unsigned long last_valid_pfn;
>  static void sun4u_pgprot_init(void);
>  static void sun4v_pgprot_init(void);
>  
> -static phys_addr_t __init available_memory(void)
> -{
> -	phys_addr_t available = 0ULL;
> -	phys_addr_t pa_start, pa_end;
> -	u64 i;
> -
> -	for_each_free_mem_range(i, NUMA_NO_NODE, MEMBLOCK_NONE, &pa_start,
> -				&pa_end, NULL)
> -		available = available + (pa_end  - pa_start);
> -
> -	return available;
> -}
> -
>  #define _PAGE_CACHE_4U	(_PAGE_CP_4U | _PAGE_CV_4U)
>  #define _PAGE_CACHE_4V	(_PAGE_CP_4V | _PAGE_CV_4V)
>  #define __DIRTY_BITS_4U	 (_PAGE_MODIFIED_4U | _PAGE_WRITE_4U | _PAGE_W_4U)
> @@ -2287,33 +2274,8 @@ static phys_addr_t __init available_memory(void)
>   */
>  static void __init reduce_memory(phys_addr_t limit_ram)
>  {
> -	phys_addr_t avail_ram = available_memory();
> -	phys_addr_t pa_start, pa_end;
> -	u64 i;
> -
> -	if (limit_ram >= avail_ram)
> -		return;
> -
> -	for_each_free_mem_range(i, NUMA_NO_NODE, MEMBLOCK_NONE, &pa_start,
> -				&pa_end, NULL) {
> -		phys_addr_t region_size = pa_end - pa_start;
> -		phys_addr_t clip_start = pa_start;
> -
> -		avail_ram = avail_ram - region_size;
> -		/* Are we consuming too much? */
> -		if (avail_ram < limit_ram) {
> -			phys_addr_t give_back = limit_ram - avail_ram;
> -
> -			region_size = region_size - give_back;
> -			clip_start = clip_start + give_back;
> -		}
> -
> -		memblock_remove(clip_start, region_size);
> -
> -		if (avail_ram <= limit_ram)
> -			break;
> -		i = 0UL;
> -	}
> +	limit_ram += memblock_reserved_size();
> +	memblock_enforce_memory_limit(limit_ram);
>  }
>  
>  void __init paging_init(void)
> -- 
> 2.7.4
> 

-- 
Sincerely yours,
Mike.

