Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 130522803E6
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 14:04:15 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id u28so3805102qtj.7
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 11:04:15 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id h26si1996101qte.315.2017.08.23.11.04.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 11:04:11 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v1 0/1] Reversed logic in memblock_discard
Date: Wed, 23 Aug 2017 14:04:00 -0400
Message-Id: <1503511441-95478-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, terraluna977@gmail.com

One line fix for reversed logic where static array is freed instead of
allocated one

Pavel Tatashin (1):
  mm: Reversed logic in memblock_discard

 mm/memblock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
