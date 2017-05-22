Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A859831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 12:09:06 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id x47so34227437uab.14
        for <linux-mm@kvack.org>; Mon, 22 May 2017 09:09:06 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id d40si8206449uag.153.2017.05.22.09.09.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 09:09:05 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v5 0/1] mm: Adaptive hash table scaling
Date: Mon, 22 May 2017 12:08:48 -0400
Message-Id: <1495469329-755807-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, mpe@ellerman.id.au

Changes from v5 - v4
- Disabled adaptive hash on 32 bit systems to avoid confusion of
  whether base should be different for smaller systems, and to
  avoid overflows.

Pavel Tatashin (1):
  mm: Adaptive hash table scaling

 mm/page_alloc.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
