Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3BBE4828E1
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 07:31:50 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id bj10so63408180pad.2
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 04:31:50 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id ji9si12688618pac.108.2016.03.02.04.31.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Mar 2016 04:31:49 -0800 (PST)
Message-ID: <56D6DC13.8060008@huawei.com>
Date: Wed, 2 Mar 2016 20:26:59 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: a question about slub in function __slab_free()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

___slab_alloc()
	deactivate_slab()
		add_full(s, n, page);
The page will be added to full list and the frozen is 0, right?

__slab_free()
	prior = page->freelist;  // prior is NULL
	was_frozen = new.frozen;  // was_frozen is 0
	...
		/*
		 * Slab was on no list before and will be
		 * partially empty
		 * We can defer the list move and instead
		 * freeze it.
		 */
		new.frozen = 1;
	...

I don't understand why "Slab was on no list before"?

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
