Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id A207B280753
	for <linux-mm@kvack.org>; Sat, 20 May 2017 13:07:03 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id g96so40713203ybi.11
        for <linux-mm@kvack.org>; Sat, 20 May 2017 10:07:03 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id l5si4074887ybb.277.2017.05.20.10.07.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 May 2017 10:07:02 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v4 0/1] mm: Adaptive hash table scaling
Date: Sat, 20 May 2017 13:06:52 -0400
Message-Id: <1495300013-653283-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org

Changes from v3 - v4:
- Fixed an issue with 32-bit overflow (adapt is ull now instead ul)
- Added changes suggested by Michal Hocko: use high_limit instead of
  a new flag to determine that we should use this new scaling.

Pavel Tatashin (1):
  mm: Adaptive hash table scaling

 mm/page_alloc.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
