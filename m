Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 42B706B13F2
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 17:44:03 -0500 (EST)
Date: Wed, 1 Feb 2012 14:44:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/5] mm: search from free_area_cache for the bigger size
Message-Id: <20120201144401.af84e3a2.akpm@linux-foundation.org>
In-Reply-To: <4F1019D3.8020709@linux.vnet.ibm.com>
References: <4F101904.8090405@linux.vnet.ibm.com>
	<4F1019D3.8020709@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: William Irwin <wli@holomorphy.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, 13 Jan 2012 19:47:31 +0800
Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com> wrote:

> If the required size is bigger than cached_hole_size, we would better search
> from free_area_cache, it is more easier to get free region, specifically for
> the 64 bit process whose address space is large enough
> 
> Do it just as hugetlb_get_unmapped_area_topdown() in arch/x86/mm/hugetlbpage.c

Can this cause additional fragmentation of the virtual address region? 
If so, what might be the implications of this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
