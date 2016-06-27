Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id B88916B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 04:28:04 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id k78so328864962ioi.2
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 01:28:04 -0700 (PDT)
Received: from mail-io0-x244.google.com (mail-io0-x244.google.com. [2607:f8b0:4001:c06::244])
        by mx.google.com with ESMTPS id v197si400946ita.98.2016.06.27.01.28.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jun 2016 01:28:04 -0700 (PDT)
Received: by mail-io0-x244.google.com with SMTP id 100so23566703ioh.1
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 01:28:04 -0700 (PDT)
MIME-Version: 1.0
From: yoma sophian <sophian.yoma@gmail.com>
Date: Mon, 27 Jun 2016 16:28:03 +0800
Message-ID: <CADUS3omw4c3Q8W76RK254Kd=yqokBCPysJ0Y7rRJGpRj4zEv4A@mail.gmail.com>
Subject: some question about vma_interval_tree_insert
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

hi all:
I try to find out where the function, vma_interval_tree_insert,
implemented but in vain.
http://lxr.free-electrons.com/ident?i=vma_interval_tree_insert

from linux cross-reference, it only show prototype defined and
referenced like below:
Defined as a function prototype in:
include/linux/mm.h, line 1919
Referenced (in 3 files total) in:
mm/mmap.c:
line 548
line 738
line 739
mm/nommu.c, line 709
include/linux/mm.h, line 1919

Would anyone help to let me know where it is implemented?
appreciate your kind help,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
