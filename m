Message-ID: <44EE8487.7070300@yahoo.com.au>
Date: Fri, 25 Aug 2006 15:03:03 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Guest page hinting patches.
References: <20060824142911.GA12127@skybase>
In-Reply-To: <20060824142911.GA12127@skybase>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org, akpm@osdl.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Martin Schwidefsky wrote:

> Any objections against pushing patch #01 and patch #02 into the
> -mm tree?

None from me. Although I'd rather put all that stuff (including
kernel_map_page, as a cleanup) into arch_free_page and
arch_alloc_page, rather than teaching core code about unstable
pages just yet.

[BTW, if you do this, one actually notices that arch_free_page seems
to be in the wrong place since the page reserved checks came into the
allocator.]

> 
> The code runs well on s390 and does nothing for all other archs.
> Patches are against 2.6.18-rc4-mm2.
> 


-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
