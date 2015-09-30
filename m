Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8EB4382F64
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 17:04:01 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so51124408pad.1
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 14:04:01 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id i16si3426943pbq.81.2015.09.30.14.04.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Sep 2015 14:04:00 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so51224115pac.0
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 14:04:00 -0700 (PDT)
Date: Wed, 30 Sep 2015 14:03:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: fix overflow in find_zone_movable_pfns_for_nodes()
In-Reply-To: <560BAC76.6050002@huawei.com>
Message-ID: <alpine.DEB.2.10.1509301403420.1148@chino.kir.corp.google.com>
References: <560BAC76.6050002@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tang Chen <tangchen@cn.fujitsu.com>, zhongjiang@huawei.com, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 30 Sep 2015, Xishi Qiu wrote:

> If user set "movablecore=xx" to a large number, corepages will overflow,
> this patch fix the problem.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
