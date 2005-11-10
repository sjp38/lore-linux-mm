Date: Wed, 9 Nov 2005 16:10:57 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 1/4] Hugetlb: Remove duplicate i_size check
Message-ID: <20051110001057.GK29402@holomorphy.com>
References: <1131578925.28383.9.camel@localhost.localdomain> <1131579410.28383.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1131579410.28383.19.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Gibson <david@gibson.dropbear.id.au>, hugh@veritas.com, rohit.seth@intel.com, kenneth.w.chen@intel.com
List-ID: <linux-mm.kvack.org>

On Wed, 2005-10-26 at 12:00 +1000, David Gibson wrote:
>> - The check against i_size was duplicated: once in
>>   find_lock_huge_page() and again in hugetlb_fault() after taking the
>>   page_table_lock.  We only really need the locked one, so remove the
>>   other.

On Wed, Nov 09, 2005 at 05:36:49PM -0600, Adam Litke wrote:
> Original post by David Gibson <david@gibson.dropbear.id.au>
> Version 2: Wed 9 Nov 2005
> 	Split this cleanup out into a standalone patch
> Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
> Signed-off-by: Adam Litke <agl@us.ibm.com>

Innocuous enough.

Acked-by: William Irwin <wli@holomorphy.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
