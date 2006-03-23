Date: Thu, 23 Mar 2006 03:47:50 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: mm/hugetlb.c/alloc_fresh_huge_page(): slow division on NUMA
Message-Id: <20060323034750.2ba076f0.akpm@osdl.org>
In-Reply-To: <20060323110831.GA14855@rhlx01.fht-esslingen.de>
References: <20060323110831.GA14855@rhlx01.fht-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Mohr <andi@rhlx01.fht-esslingen.de>
Cc: linux-kernel@vger.kernel.org, lse-tech@lists.sourceforge.net, linux-mm@kvack.org, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Andreas Mohr <andi@rhlx01.fht-esslingen.de> wrote:
>
> on NUMA there
>  indeed is an idiv opcode in the mm/hugetlb.o output:
> 
>   138:   e8 fc ff ff ff          call   139 <alloc_fresh_huge_page+0x32>

Stop looking at ancient 2.6.16 kernels.  That code isn't there any more ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
