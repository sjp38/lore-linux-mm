Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3566B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 22:31:06 -0400 (EDT)
Received: by pabws5 with SMTP id ws5so8068277pab.1
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 19:31:05 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id hd5si9392606pbb.257.2015.10.13.19.31.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Oct 2015 19:31:05 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so38890817pac.3
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 19:31:05 -0700 (PDT)
Date: Tue, 13 Oct 2015 19:31:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: skip if required_kernelcore is larger than
 totalpages
In-Reply-To: <5615D311.5030908@huawei.com>
Message-ID: <alpine.DEB.2.10.1510131930520.12718@chino.kir.corp.google.com>
References: <5615D311.5030908@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Tang Chen <tangchen@cn.fujitsu.com>, zhongjiang@huawei.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 8 Oct 2015, Xishi Qiu wrote:

> If kernelcore was not specified, or the kernelcore size is zero
> (required_movablecore >= totalpages), or the kernelcore size is larger
> than totalpages, there is no ZONE_MOVABLE. We should fill the zone
> with both kernel memory and movable memory.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
