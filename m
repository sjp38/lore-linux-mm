Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2936B0031
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 00:40:30 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kq14so550087pab.9
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 21:40:29 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id hh1si427458pac.382.2014.03.12.21.40.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 12 Mar 2014 21:40:29 -0700 (PDT)
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0N2C0039SYBDODE0@mailout3.samsung.com> for linux-mm@kvack.org;
 Thu, 13 Mar 2014 13:40:25 +0900 (KST)
Message-id: <532136C1.5020502@samsung.com>
Date: Thu, 13 Mar 2014 13:40:33 +0900
From: Heesub Shin <heesub.shin@samsung.com>
MIME-version: 1.0
Subject: Re: cma: alloc_contig_range test_pages_isolated .. failed
References: <CAA6Yd9V=RJpysp1u3_+nA6ttWMNdYdRTn1o8fyOX35faaOtx2w@mail.gmail.com>
In-reply-to: 
 <CAA6Yd9V=RJpysp1u3_+nA6ttWMNdYdRTn1o8fyOX35faaOtx2w@mail.gmail.com>
Content-type: text/plain; charset=UTF-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ramakrishnan Muthukrishnan <vu3rdd@gmail.com>, linux-mm@kvack.org

Hello,

On 03/11/2014 11:02 PM, Ramakrishnan Muthukrishnan wrote:
> [   26.846313] alloc_contig_range test_pages_isolated(a2e00, a3400) failed
> [   26.853515] alloc_contig_range test_pages_isolated(a2e00, a3500) failed
> [   26.860809] alloc_contig_range test_pages_isolated(a3100, a3700) failed
> [   26.868133] alloc_contig_range test_pages_isolated(a3200, a3800) failed

"memory-hotplug: fix pages missed by race rather than failing" by 
Minchan Kim (435b405) would also help you, which was merged after v3.4.

--
Regards,
heesub

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
