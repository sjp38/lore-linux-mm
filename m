Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA24786
	for <linux-mm@kvack.org>; Mon, 24 Feb 2003 14:36:39 -0800 (PST)
Date: Mon, 24 Feb 2003 14:33:41 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] pte_alloc_kernel needs additional check
Message-Id: <20030224143341.0b3e1faa.akpm@digeo.com>
In-Reply-To: <1046123680.13919.67.camel@plars>
References: <1046123680.13919.67.camel@plars>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Larson <plars@linuxtestproject.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Paul Larson <plars@linuxtestproject.org> wrote:
>
> This applies against 2.5.63.
> pte_alloc_kernel needs a check for pmd_present(*pmd) at the end.
> 
> Thanks,
> Paul Larson
> 
> --- linux-2.5.63/mm/memory.c	Mon Feb 24 13:05:31 2003
> +++ linux-2.5.63-fix/mm/memory.c	Mon Feb 24 15:45:05 2003
> @@ -186,7 +186,9 @@
>  		pmd_populate_kernel(mm, pmd, new);
>  	}
>  out:
> -	return pte_offset_kernel(pmd, address);
> +	if (pmd_present(*pmd))
> +		return pte_offset_kernel(pmd, address);
> +	return NULL;
>  }
>  #define PTE_TABLE_MASK	((PTRS_PER_PTE-1) * sizeof(pte_t))
>  #define PMD_TABLE_MASK	((PTRS_PER_PMD-1) * sizeof(pmd_t))

Confused.  I cannot see a codepath which makes this test necessary?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
