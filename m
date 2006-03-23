Date: Thu, 23 Mar 2006 12:56:01 +0100
From: Andreas Mohr <andim2@users.sourceforge.net>
Subject: Re: mm/hugetlb.c/alloc_fresh_huge_page(): slow division on NUMA
Message-ID: <20060323115601.GA1044@rhlx01.fht-esslingen.de>
Reply-To: andi@lisas.de
References: <20060323110831.GA14855@rhlx01.fht-esslingen.de> <20060323034750.2ba076f0.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060323034750.2ba076f0.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, lse-tech@lists.sourceforge.net, linux-mm@kvack.org, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Mar 23, 2006 at 03:47:50AM -0800, Andrew Morton wrote:
> Andreas Mohr <andi@rhlx01.fht-esslingen.de> wrote:
> >
> > on NUMA there
> >  indeed is an idiv opcode in the mm/hugetlb.o output:
> > 
> >   138:   e8 fc ff ff ff          call   139 <alloc_fresh_huge_page+0x32>
> 
> Stop looking at ancient 2.6.16 kernels.  That code isn't there any more ;)
Hrmpf. I had just gotten some awful suspicion when looking at 2.6.16-mm1
changelog mentioning hugemem changes. Oh well...

I'm going to hunt for similar modulo cases in the future.

Andreas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
