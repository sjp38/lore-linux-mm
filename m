Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f47.google.com (mail-lf0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0BBA56B0038
	for <linux-mm@kvack.org>; Sun, 13 Dec 2015 15:16:51 -0500 (EST)
Received: by lfcy184 with SMTP id y184so34697949lfc.1
        for <linux-mm@kvack.org>; Sun, 13 Dec 2015 12:16:50 -0800 (PST)
Received: from mail-lf0-x230.google.com (mail-lf0-x230.google.com. [2a00:1450:4010:c07::230])
        by mx.google.com with ESMTPS id vz8si15494607lbb.124.2015.12.13.12.16.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Dec 2015 12:16:49 -0800 (PST)
Received: by lfed137 with SMTP id d137so57048923lfe.3
        for <linux-mm@kvack.org>; Sun, 13 Dec 2015 12:16:49 -0800 (PST)
Message-Id: <20151213201418.251001596@gmail.com>
Date: Sun, 13 Dec 2015 23:14:18 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [RFC 0/2] Turn RLIMIT_DATA to account anonymous mappings
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Vegard Nossum <vegard.nossum@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Willy Tarreau <w@1wt.eu>, Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@google.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Cyrill Gorcunov <gorcunov@openvz.org>

Take a look please, once time permit. Hopefully I didnt
miss something obvious (it's been spinning on my VM
for sometime without problem but if there some more
tests which can be runned please point me).

The second version is slightly different because
I added rlimit-data tests for do_brk and mremap.

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
