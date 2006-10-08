Message-ID: <452856E4.60705@yahoo.com.au>
Date: Sun, 08 Oct 2006 11:39:48 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 3/3] mm: add arch_alloc_page
References: <20061007105758.14024.70048.sendpatchset@linux.site>	<20061007105824.14024.85405.sendpatchset@linux.site> <20061007134345.0fa1d250.akpm@osdl.org>
In-Reply-To: <20061007134345.0fa1d250.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>On Sat,  7 Oct 2006 15:06:04 +0200 (CEST)
>Nick Piggin <npiggin@suse.de> wrote:
>
>
>>Add an arch_alloc_page to match arch_free_page.
>>
>
>umm.. why?
>

I had a future patch to more kernel_map_pages into it, but couldn't
decide if that's a generic kernel feature that is only implemented in
2 architectures, or an architecture speicifc feature. So I left it out.

But at least Martin wanted a hook here for his volatile pages patches,
so I thought I'd submit this patch anyway.

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
