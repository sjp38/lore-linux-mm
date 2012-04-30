Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id CB26C6B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 12:24:56 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 30 Apr 2012 10:24:56 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 5F1E21FF0068
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 10:24:48 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3UGOe8o062560
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 10:24:45 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3UGObpx021459
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 10:24:40 -0600
Message-ID: <4F9EBCC3.9040509@linux.vnet.ibm.com>
Date: Mon, 30 Apr 2012 11:24:35 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] zsmalloc: make zsmalloc portable
References: <1335334994-22138-1-git-send-email-minchan@kernel.org> <1335334994-22138-7-git-send-email-minchan@kernel.org> <4F980AFE.60901@vflare.org> <fcde09be-ae34-4f09-a324-825fb2d4fac2@default> <4F98ACF3.7060908@kernel.org> <4F98D814.9060808@kernel.org>
In-Reply-To: <4F98D814.9060808@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/26/2012 12:07 AM, Minchan Kim wrote:

> 
> Quick patch - totally untested.
> 
> We can implement new TLB flush function 
> "local_flush_tlb_kernel_range" If architecture is very smart, it 
> could flush only tlb entries related to vaddr. If architecture is 
> smart, it could flush only tlb entries related to a CPU. If 
> architecture is _NOT_ smart, it could flush all entries of all CPUs.
> 
> Now there are few architectures have "local_flush_tlb_kernel_range". 
> MIPS, sh, unicore32, arm, score and x86 by this patch. So I think 
> it's good candidate other arch should implement. Until that, we can 
> add stub for other architectures which calls only [global/local] TLB
>  flush. We can expect maintainer could respond then they can 
> implement best efficient method. If the maintainer doesn't have any 
> interest, zsmalloc could be very slow in that arch and users will 
> blame that architecture.
> 
> Any thoughts?


I had this same idea a while back.

It is encouraging to know that someone else independently thought of
this solution too :)  Makes me think it is a good solution.

Let me build and test on x86, make sure there are no unforseen consequences.

Thanks again for your work here!

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
