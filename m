Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id A9F2C6B0037
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 04:42:28 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so5259123pbb.3
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 01:42:28 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id ob10si8390882pbb.157.2013.12.16.01.42.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 01:42:27 -0800 (PST)
Message-ID: <52AECABE.60902@huawei.com>
Date: Mon, 16 Dec 2013 17:41:18 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix huge page reallocated in soft_offline_page
References: <52AEC122.2000609@huawei.com>
In-Reply-To: <52AEC122.2000609@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, WuJianguo <wujianguo@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2013/12/16 17:00, Xishi Qiu wrote:

> The huge page may be reallocated in soft_offline_page, because
> MIGRATE_ISOLATE can not keep the page until after setting PG_hwpoison.
> alloc_huge_page()
> 	dequeue_huge_page_vma()
> 		dequeue_huge_page_node()
> If the huge page was reallocated, we need to try offline it again.
> 

Sorry, I made a mistake.
This bug was fixed in
commit c8721bbbdd36382de51cd6b7a56322e0acca2414

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
