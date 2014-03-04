Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4AA356B003A
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 21:48:59 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id kq14so4616864pab.37
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 18:48:58 -0800 (PST)
Received: from mail-pb0-x22e.google.com (mail-pb0-x22e.google.com [2607:f8b0:400e:c01::22e])
        by mx.google.com with ESMTPS id tm9si12548073pab.47.2014.03.03.18.48.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Mar 2014 18:48:58 -0800 (PST)
Received: by mail-pb0-f46.google.com with SMTP id rq2so4602095pbb.33
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 18:48:58 -0800 (PST)
From: Pradeep Sawlani <pradeep.sawlani@gmail.com>
Subject: [PATCH RFC 0/1] ksm: check and skip page, if it is already scanned
Date: Mon,  3 Mar 2014 18:48:52 -0800
Message-Id: <1393901333-5569-1-git-send-email-pradeep.sawlani@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>
Cc: LKML <linux-kernel@vger.kernel.org>, MEMORY MANAGEMENT <linux-mm@kvack.org>, Dave Hansen <dave@sr71.net>, Arjan van de Ven <arjan@linux.intel.com>, Suri Maddhula <surim@amazon.com>, Matt Wilson <msw@amazon.com>, Anthony Liguori <aliguori@amazon.com>, Pradeep Sawlani <sawlani@amazon.com>

From: Pradeep Sawlani <sawlani@amazon.com>

Patch uses two bits to detect if page is scanned, one bit for odd cycle
and other for even cycle. This adds one more bit in page flags and
overloads existing bit (PG_owner_priv_1).
Changes are based of 3.4.79 kernel, since I have used that for verification.
Detail discussion can be found at https://lkml.org/lkml/2014/2/13/624
Suggestion(s) are welcome for alternative solution in order to avoid one more
bit in page flags.

Pradeep Sawlani (1):
  ksm: check and skip page, if it is already scanned

 include/linux/page-flags.h |   11 +++++++++++
 mm/Kconfig                 |   10 ++++++++++
 mm/ksm.c                   |   33 +++++++++++++++++++++++++++++++--
 3 files changed, 52 insertions(+), 2 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
