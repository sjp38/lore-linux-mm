Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k17L6HZ5024818
	for <linux-mm@kvack.org>; Tue, 7 Feb 2006 16:06:17 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k17L6G9P182274
	for <linux-mm@kvack.org>; Tue, 7 Feb 2006 16:06:17 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k17L6GcK023146
	for <linux-mm@kvack.org>; Tue, 7 Feb 2006 16:06:16 -0500
Message-ID: <43E90BC1.7010907@austin.ibm.com>
Date: Tue, 07 Feb 2006 15:06:09 -0600
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH 4/9] ppc64 - Specify amount of kernel memory
 at boot time
References: <20060126184305.8550.94358.sendpatchset@skynet.csn.ul.ie> <20060126184425.8550.64598.sendpatchset@skynet.csn.ul.ie>
In-Reply-To: <20060126184425.8550.64598.sendpatchset@skynet.csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

> This patch adds the kernelcore= parameter for ppc64

...

> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.16-rc1-mm3-103_x86coremem/mm/page_alloc.c linux-2.6.16-rc1-mm3-104_ppc64coremem/mm/page_alloc.c
> --- linux-2.6.16-rc1-mm3-103_x86coremem/mm/page_alloc.c	2006-01-26 18:09:04.000000000 +0000
> +++ linux-2.6.16-rc1-mm3-104_ppc64coremem/mm/page_alloc.c	2006-01-26 18:10:29.000000000 +0000

Not to nitpick, but this chunk should go in a different patch, it's not 
ppc64 specific.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
