Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id CF8686B00E4
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 00:48:47 -0500 (EST)
Received: by mail-ie0-f182.google.com with SMTP id k14so6842944iea.27
        for <linux-mm@kvack.org>; Mon, 04 Feb 2013 21:48:47 -0800 (PST)
Message-ID: <1360043326.2403.2.camel@kernel.cn.ibm.com>
Subject: Re: Support variable-sized huge pages
From: Ric Mason <ric.masonn@gmail.com>
Date: Mon, 04 Feb 2013 23:48:46 -0600
In-Reply-To: <20130131105227.GI30577@one.firstfloor.org>
References: <1359620590.1391.5.camel@kernel>
	 <20130131105227.GI30577@one.firstfloor.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>

Hi Andi,
On Thu, 2013-01-31 at 11:52 +0100, Andi Kleen wrote:
> On Thu, Jan 31, 2013 at 02:23:10AM -0600, Ric Mason wrote:
> > Hi all,
> > 
> > It seems that Andi's "Support more pagesizes for
> > MAP_HUGETLB/SHM_HUGETLB" patch has already merged. According to the
> > patch, x86 will support 2MB and 1GB huge pages. But I just see 
> > hugepages-2048kB under /sys/kernel/mm/hugepages/ on my x86_32 PAE desktop.
> > Where is 1GB huge pages?
> 
> 1GB pages are only supported under 64bit kernels, and also
> only if you allocate them explicitely with boot options.

I am curious about how can buddy system alloc 1GB huge pages? the most
order buddy system supports is 10. Could you explain to me? 

> 
> -Andi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
