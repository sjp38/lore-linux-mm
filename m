Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id BA3086B0005
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:49:13 -0500 (EST)
Received: by mail-qg0-f53.google.com with SMTP id y9so145479944qgd.3
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 10:49:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k92si24190536qgk.39.2016.02.23.10.49.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 10:49:13 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/1] Re: THP race?
Date: Tue, 23 Feb 2016 19:49:09 +0100
Message-Id: <1456253350-3959-1-git-send-email-aarcange@redhat.com>
In-Reply-To: <20160223154950.GA22449@node.shutemov.name>
References: <20160223154950.GA22449@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "\\\"Kirill A. Shutemov\\\"" <kirill@shutemov.name>
Cc: linux-mm@kvack.org

Hello Kirill and Andrew,

Resending as a more proper submit with slightly improved commentary
and that builds and boots..

Andrea Arcangeli (1):
  mm: thp: fix SMP race condition between THP page fault and
    MADV_DONTNEED

 mm/memory.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
