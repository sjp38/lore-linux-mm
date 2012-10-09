Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 5D0806B002B
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 20:37:20 -0400 (EDT)
Received: from eusync2.samsung.com (mailout3.w1.samsung.com [210.118.77.13])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MBL003L1OEZ4E80@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 09 Oct 2012 01:37:47 +0100 (BST)
Received: from [172.16.228.128] ([10.90.7.109])
 by eusync2.samsung.com (Oracle Communications Messaging Server 7u4-23.01
 (7.0.4.23.0) 64bit (built Aug 10 2011))
 with ESMTPA id <0MBL00FMNOE31V80@eusync2.samsung.com> for linux-mm@kvack.org;
 Tue, 09 Oct 2012 01:37:18 +0100 (BST)
Message-id: <507371DA.9080309@samsung.com>
Date: Tue, 09 Oct 2012 02:37:46 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: CMA and zone watermarks
References: <CAH+eYFCJTtF+FeqKs_ho5yyX0tkUBoaa-yfsd1rVshcQ5Xxp=A@mail.gmail.com>
In-reply-to: 
 <CAH+eYFCJTtF+FeqKs_ho5yyX0tkUBoaa-yfsd1rVshcQ5Xxp=A@mail.gmail.com>
Content-type: text/plain; charset=ISO-8859-1; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rabin Vincent <rabin@rab.in>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hello,

On 10/8/2012 5:41 PM, Rabin Vincent wrote:

> It appears that when CMA is enabled, the zone watermarks are not properly
> respected, leading to for example GFP_NOWAIT allocations getting access to the
> high pools.
>
> I ran the following test code which simply allocates pages with GFP_NOWAIT
> until it fails, and then tries GFP_ATOMIC.  Without CMA, the GFP_ATOMIC
> allocation succeeds, with CMA, it fails too.

Could You run your test with latest linux-next kernel? There have been 
some patches merged to akpm tree which should fix accounting for free 
and free cma pages. I hope it should fix this issue.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
