Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 03FA36B0023
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 13:15:05 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id i127so1569824pgc.22
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 10:15:04 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id w6-v6si3552601plp.547.2018.03.28.10.15.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 10:15:03 -0700 (PDT)
Subject: Re: [PATCHv2 06/14] mm/page_alloc: Propagate encryption KeyID through
 page allocator
References: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
 <20180328165540.648-7-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <5d334638-2139-07a1-c999-36a1729173fb@intel.com>
Date: Wed, 28 Mar 2018 10:15:02 -0700
MIME-Version: 1.0
In-Reply-To: <20180328165540.648-7-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/28/2018 09:55 AM, Kirill A. Shutemov wrote:
> @@ -51,7 +51,7 @@ static inline struct page *new_page_nodemask(struct page *page,
>  	if (PageHighMem(page) || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
>  		gfp_mask |= __GFP_HIGHMEM;
>  
> -	new_page = __alloc_pages_nodemask(gfp_mask, order,
> +	new_page = __alloc_pages_nodemask(gfp_mask, order, page_keyid(page),
>  				preferred_nid, nodemask);

You're not going to like this suggestion.

Am I looking at this too superficially, or does every single site into
which you pass keyid also take a node and gfpmask and often an order?  I
think you need to run this by the keepers of page_alloc.c and see if
they'd rather do something more drastic.
