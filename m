Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 701E46B772C
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 01:49:49 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id h4-v6so4983206pls.17
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 22:49:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q12-v6si4624264pfc.349.2018.09.05.22.49.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 22:49:48 -0700 (PDT)
Date: Thu, 6 Sep 2018 07:49:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 2/2] mm: Create non-atomic version of SetPageReserved
 for init use
Message-ID: <20180906054946.GK14951@dhcp22.suse.cz>
References: <20180905211041.3286.19083.stgit@localhost.localdomain>
 <20180905211334.3286.84435.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180905211334.3286.84435.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alexander.h.duyck@intel.com, pavel.tatashin@microsoft.com, dave.hansen@intel.com, akpm@linux-foundation.org, mingo@kernel.org, kirill.shutemov@linux.intel.com

On Wed 05-09-18 14:13:34, Alexander Duyck wrote:
[...]

just a nit

> @@ -1231,7 +1231,8 @@ void __meminit reserve_bootmem_region(phys_addr_t start, phys_addr_t end)
>  			/* Avoid false-positive PageTail() */
>  			INIT_LIST_HEAD(&page->lru);
>  
> -			SetPageReserved(page);
> +			/* no need for atomic set_bit at init time */
> +			__SetPageReserved(page);

OK but I guess it would be much more clear to say
			/*
			 * no need for atomic set_bit because the struct
			 * page is not visible yet so nobody should
			 * access it yet.
			 */
>  		}
>  	}
>  }
-- 
Michal Hocko
SUSE Labs
