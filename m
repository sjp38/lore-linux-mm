Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0CC416B16F3
	for <linux-mm@kvack.org>; Sun, 19 Aug 2018 23:26:45 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id w126-v6so13661637qka.11
        for <linux-mm@kvack.org>; Sun, 19 Aug 2018 20:26:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x61-v6si685265qvx.96.2018.08.19.20.26.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Aug 2018 20:26:44 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/1] fix for "pathological THP behavior" v2
Date: Sun, 19 Aug 2018 23:26:39 -0400
Message-Id: <20180820032640.9896-1-aarcange@redhat.com>
In-Reply-To: <20180820032204.9591-3-aarcange@redhat.com>
References: <20180820032204.9591-3-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

Hello,

This would be the other option which also works well, but changes the
behavior of MADV_HUGEPAGE and defrag="always" to prioritize THP
generation over NUMA locality.

Thanks,
Andrea

Andrea Arcangeli (1):
  mm: thp: fix transparent_hugepage/defrag = madvise || always

 mm/mempolicy.c | 32 ++++++++++++++++++++++++++++++--
 1 file changed, 30 insertions(+), 2 deletions(-)
