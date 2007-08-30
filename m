Message-ID: <46D67182.8080408@yahoo.com.au>
Date: Thu, 30 Aug 2007 17:28:02 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 7/9] pagewalk: add handler for empty ranges
References: <20070821204248.0F506A29@kernel> <20070821204256.140D32D2@kernel>
In-Reply-To: <20070821204256.140D32D2@kernel>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:

> @@ -27,25 +23,23 @@ static int walk_pmd_range(pud_t *pud, un
>  {
>  	pmd_t *pmd;
>  	unsigned long next;
> -	int err;
> +	int err = 0;
>  
>  	for (pmd = pmd_offset(pud, addr); addr != end;
>  	     pmd++, addr = next) {
>  		next = pmd_addr_end(addr, end);

While you're there, do you mind fixing the actual page table walking so
that it follows the normal form?

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
