Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 56B776B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 03:22:07 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l43so4717758wre.4
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 00:22:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d62si1520151wmc.155.2017.03.24.00.22.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Mar 2017 00:22:06 -0700 (PDT)
Date: Fri, 24 Mar 2017 08:22:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: fix a coding style issue
Message-ID: <20170324072203.GA14875@dhcp22.suse.cz>
References: <20170323074902.23768-1-kristaps.civkulis@gmail.com>
 <52c53f8a-ef23-46ce-040b-d63498a7dfa5@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52c53f8a-ef23-46ce-040b-d63498a7dfa5@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kristaps Civkulis <kristaps.civkulis@gmail.com>
Cc: akpm@linux-foundation.org, mike.kravetz@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 23-03-17 10:12:44, Kristaps Civkulis wrote:
> Fix a coding style issue.

I believe style fixes are worth applying only when part of a larger
change which does something useful or where the resulting code is much
easier to read. This doesn't seem to be the case here.
 
> Signed-off-by: Kristaps Civkulis <kristaps.civkulis@gmail.com>
> ---
> Resend, because it should be only [PATCH] in subject.
> ---
>  mm/hugetlb.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 3d0aab9ee80d..4c72c1974c8c 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1916,8 +1916,7 @@ static long __vma_reservation_common(struct hstate *h,
>  			return 0;
>  		else
>  			return 1;
> -	}
> -	else
> +	} else
>  		return ret < 0 ? ret : 0;
>  }
> 
> -- 
> 2.12.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
