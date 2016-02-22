Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id A19E66B0255
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 21:57:18 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id c10so87275760pfc.2
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 18:57:18 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id rq5si31008321pab.126.2016.02.21.18.57.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 21 Feb 2016 18:57:18 -0800 (PST)
Message-ID: <56CA78F7.9010201@huawei.com>
Date: Mon, 22 Feb 2016 10:56:55 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC] mm: why we should clear page when do anonymous page fault
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

handle_pte_fault()
	do_anonymous_page()
		alloc_zeroed_user_highpage_movable()

We will alloc a zeroed page when do anonymous page fault, I don't know
why should clear it? just for safe?

If user space program do like the following, there are two memset 0, right?
kernel alloc zeroed page, and user memset 0 it again, this will waste a
lot of time.

main()
{
	...
	vaddr = malloc(size)
	if (vaddr)
		memset(vaddr, 0, size);
	...
}


Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
