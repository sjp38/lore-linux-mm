Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 209256B0038
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 20:42:17 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id fp1so1111925pdb.37
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 17:42:16 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id vw10si198251pbc.167.2014.02.12.17.42.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Feb 2014 17:42:16 -0800 (PST)
Message-ID: <52FC22E6.9010300@huawei.com>
Date: Thu, 13 Feb 2014 09:41:58 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [request for stable inclusion] mm/memory-failure.c: fix memory leak
 in successful soft offlining
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, kirill.shutemov@linux.intel.com, hughd@google.com
Cc: Linux MM <linux-mm@kvack.org>, Xishi Qiu <qiuxishi@huawei.com>, Li Zefan <lizefan@huawei.com>, Wang Nan <wangnan0@huawei.com>

Hi Naoya or Greg,

f15bdfa802bfa5eb6b4b5a241b97ec9fa1204a35
mm/memory-failure.c: fix memory leak in successful soft offlining

This patche look applicable to stable-3.10.
After a successful page migration by soft offlining, the source 
page is not properly freed and it's never reusable even if we 
unpoison it afterward. This is caused by the race between freeing 
page and setting PG_hwpoison.
It was built successful for me. What do you think?

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
