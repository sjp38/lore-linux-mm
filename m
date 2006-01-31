Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0VIm4iT028570
	for <linux-mm@kvack.org>; Tue, 31 Jan 2006 13:48:04 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0VIm4YB199158
	for <linux-mm@kvack.org>; Tue, 31 Jan 2006 13:48:04 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k0VIm3uA025454
	for <linux-mm@kvack.org>; Tue, 31 Jan 2006 13:48:03 -0500
Message-ID: <43DFB0D7.3070805@us.ibm.com>
Date: Tue, 31 Jan 2006 12:47:51 -0600
From: Brian Twichell <tbrian@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC] Shared page tables
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]> <Pine.LNX.4.61.0601202020001.8821@goblin.wat.veritas.com> <43DAA3C9.9070105@us.ibm.com> <200601301246.27455.raybry@mpdtxmail.amd.com>
In-Reply-To: <200601301246.27455.raybry@mpdtxmail.amd.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@mpdtxmail.amd.com>
Cc: Hugh Dickins <hugh@veritas.com>, Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ray Bryant wrote:

>On Friday 27 January 2006 16:50, Brian Twichell wrote:
><snip>
>
>  
>
>>Hi,
>>
>>We collected more granular performance data for the ppc64/hugepage case.
>>
>>CPI decreased by 3% when shared pagetables were used.  Underlying this was
>>a 7% decrease in the overall TLB miss rate.  The TLB miss rate for
>>hugepages decreased 39%.  TLB miss rates are calculated per instruction
>>executed.
>>
>>    
>>
>
>Interesting.
>
>Do you know if Dave's patch supports sharing of pte's for 2 MB pages on 
>X86_64?
>  
>
I believe it does.  Dave, can you confirm ?

>Was there a corresponding improvement in overall transaction throughput for 
>the hugetlb, shared pte case?    That is, did the 3% improvement in CPI 
>translate to a measurable improvement in the overall OLTP benchmark score?
>  
>
Yes.  My original post with performance data described a 3% improvement
in the ppc64/hugepage case.  This is a transaction throughput statement.

>(I'm assuming your 25-50% improvement measurements, as mentioned in a previous 
>note, was for small pages.)
>
>  
>
That's correct.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
