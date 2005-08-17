Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j7HJIAFc002019
	for <linux-mm@kvack.org>; Wed, 17 Aug 2005 15:18:10 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j7HJIAKl294988
	for <linux-mm@kvack.org>; Wed, 17 Aug 2005 15:18:10 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j7HJI9Mj022915
	for <linux-mm@kvack.org>; Wed, 17 Aug 2005 15:18:09 -0400
Subject: Re: [PATCH 1/4] x86-pte_huge
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1124305384.3139.39.camel@localhost.localdomain>
References: <1124304966.3139.37.camel@localhost.localdomain>
	 <1124305384.3139.39.camel@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 17 Aug 2005 12:18:06 -0700
Message-Id: <1124306286.5879.20.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, christoph@lameter.com, ak@suse.de, kenneth.w.chen@intel.com, david@gibson.dropbear.id.au
List-ID: <linux-mm.kvack.org>

On Wed, 2005-08-17 at 14:03 -0500, Adam Litke wrote:
> @@ -254,8 +255,8 @@ extern inline int pte_dirty(pte_t pte)              
>  extern inline int pte_young(pte_t pte)         { return pte_val(pte) & _PAGE_ACCESSED; }
>  extern inline int pte_write(pte_t pte)         { return pte_val(pte) & _PAGE_RW; }
>  static inline int pte_file(pte_t pte)          { return pte_val(pte) & _PAGE_FILE; }
> +static inline int pte_huge(pte_t pte)           { return (pte_val(pte) & __LARGE_PTE) == __LARGE_PTE; }

Looks like a little whitespace issue.  Probably just tabs vs. spaces.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
