Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1BBB06B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 02:07:46 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id is5so55719326obc.0
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 23:07:46 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id xs11si4458345oec.89.2016.01.21.23.07.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jan 2016 23:07:45 -0800 (PST)
Message-ID: <56A1D52B.6060002@huawei.com>
Date: Fri, 22 Jan 2016 15:07:23 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC] mm: shall we add an entry in meminfo to show the memory from
 module?
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Currently /proc/meminfo will not show the memory from module.

This entry "VmallocUsed: xxx" only shows the memory in the range
[VMALLOC_START, VMALLOC_END] alloced by vmalloc() ->... -> __vmalloc_node_range().

The memory which used by module is from module_alloc() -> __vmalloc_node_range().

So we will miss some memory when we calculate the total in meminfo.

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
