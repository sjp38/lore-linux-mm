Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 9DFF16B0100
	for <linux-mm@kvack.org>; Wed, 23 May 2012 16:53:47 -0400 (EDT)
Received: from /spool/local
	by e1.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 23 May 2012 16:53:45 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 7CD8A6E8054
	for <linux-mm@kvack.org>; Wed, 23 May 2012 16:51:54 -0400 (EDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4NKplTp22282436
	for <linux-mm@kvack.org>; Wed, 23 May 2012 16:51:48 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4NKpkeW023186
	for <linux-mm@kvack.org>; Wed, 23 May 2012 14:51:47 -0600
Message-ID: <4FBD4DDF.5080905@linux.vnet.ibm.com>
Date: Wed, 23 May 2012 15:51:43 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/3] zsmalloc: support zsmalloc to ARM, MIPS, SUPERH
References: <1337133919-4182-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1337133919-4182-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Paul Mundt <lethal@linux-sh.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Chen Liqin <liqin.chen@sunplusct.com>

On 05/15/2012 09:05 PM, Minchan Kim wrote:

> zsmalloc uses set_pte and __flush_tlb_one for performance but
> many architecture don't support it. so this patch removes
> set_pte and __flush_tlb_one which are x86 dependency.
> Instead of it, use local_flush_tlb_kernel_range which are available
> by more architectures. It would be better than supporting only x86
> and last patch in series will enable again with supporting
> local_flush_tlb_kernel_range in x86.
> 
> About local_flush_tlb_kernel_range,
> If architecture is very smart, it could flush only tlb entries related to vaddr.
> If architecture is smart, it could flush only tlb entries related to a CPU.
> If architecture is _NOT_ smart, it could flush all entries of all CPUs.
> So, it would be best to support both portability and performance.
> 
> Cc: Russell King <linux@arm.linux.org.uk>
> Cc: Ralf Baechle <ralf@linux-mips.org>
> Cc: Paul Mundt <lethal@linux-sh.org>
> Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
> Cc: Chen Liqin <liqin.chen@sunplusct.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>


For the zsmalloc changes:

Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
