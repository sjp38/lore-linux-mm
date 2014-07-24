Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 251936B0037
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 08:10:31 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so3741659pab.26
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 05:10:30 -0700 (PDT)
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
        by mx.google.com with ESMTPS id xh5si5785124pbc.140.2014.07.24.05.10.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Jul 2014 05:10:26 -0700 (PDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so3811079pab.20
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 05:10:26 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 24 Jul 2014 08:10:25 -0400
Message-ID: <CA+C-WL8FD7hwXPTHdhjbRZ5j0bg3HZ_jgVhX_KoX6GzpjsEmew@mail.gmail.com>
Subject: Requesting help in understanding commit 7cccd8, i.e. disabling
 preemption in slub.c:slab_alloc_node
From: Patrick Palka <patrick@parcs.ath.cx>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi everybody,

I am trying to figure out the race condition that commit 7cccd8 fixes.
The commit disables preemption in between the retrieval of the per-cpu
slab and the subsequent read of the slab's tid. According to the
commit message, this change helps avoid allocating from the wrong node
in slab_alloc. But try as I might, I can't see how allocating from the
wrong node, let alone the wrong cpu, could ever happen with or without
preemption. Isn't the globally-unique per-cpu tid the mechanism that's
supposed to guard against allocating from the wrong cpu or node? In
what way does this mechanism fail in slab_alloc_node, and how does
disabling preemption during the retrieval of the tid mitigate this
failure? Would really appreciate if somebody took the time to explain
this to a newbie like me.

Thanks,
Patrick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
