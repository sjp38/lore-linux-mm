Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 288FA6B004D
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 10:35:40 -0400 (EDT)
Received: by vcbfk14 with SMTP id fk14so3023011vcb.14
        for <linux-mm@kvack.org>; Fri, 13 Apr 2012 07:35:39 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 13 Apr 2012 22:35:39 +0800
Message-ID: <CAN1soZzEuhQQYf7fNqOeMYT3Z-8VMix+1ihD77Bjtf+Do3x3DA@mail.gmail.com>
Subject: how to avoid allocating or freeze MOVABLE memory in userspace
From: Haojian Zhuang <haojian.zhuang@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, m.szyprowski@samsung.com

Hi all,

I have one question on memory migration. As we know, malloc() from
user app will allocate MIGRATE_MOVABLE pages. But if we want to use
this memory as DMA usage, we can't accept MIGRATE_MOVABLE type. Could
we change its behavior before DMA working?

Thanks
Haojian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
