Message-ID: <3DD40374.9050001@unix-os.sc.intel.com>
Date: Thu, 14 Nov 2002 12:11:32 -0800
From: Rohit Seth <rseth@unix-os.sc.intel.com>
MIME-Version: 1.0
Subject: Re: [patch] remove hugetlb syscalls
References: <Pine.LNX.4.44L.0211132239370.3817-100000@imladris.surriel.com> <08a601c28bbb$2f6182a0$760010ac@edumazet> <20021114141310.A25747@infradead.org> <002b01c28bf0$751a3960$760010ac@edumazet> <20021114103147.A17468@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>, rohit.seth@intel.com
Cc: dada1 <dada1@cosmosbay.com>, Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@conectiva.com.br>, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Benjamin LaHaise wrote:

>On Thu, Nov 14, 2002 at 04:13:56PM +0100, dada1 wrote:
>  
>
>>Thanks Christoph
>>
>>If I asked, this is because I tried the obvious and it doesnt work.
>>    
>>
>
>It's a file.  You need to use MAP_SHARED.
>  
>
This is not the problem with MAP_SHARED.  It is the lack of  (arch 
specific) hugepage aligned function support in the kernel. You can use 
the mmap on hugetlbfs using only MAP_FIXED with properly aligned 
addresses (but then this also is only a hint to kernel).  With addr == 
 NULL in mmap, the function is bound to fail almost all the times.


Thanks Ben for letting me know the problem with previous post.

>  
>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
