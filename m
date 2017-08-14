Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 81E846B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 07:14:27 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 49so7920087wrw.12
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 04:14:27 -0700 (PDT)
Received: from mout.web.de (mout.web.de. [217.72.192.78])
        by mx.google.com with ESMTPS id 74si5394749wrc.395.2017.08.14.04.14.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 04:14:26 -0700 (PDT)
From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/2] zpool: Adjustments for zpool_create_pool()
Message-ID: <0fec59a9-ac68-33f6-533a-adfb5fa3c380@users.sourceforge.net>
Date: Mon, 14 Aug 2017 13:14:21 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 14 Aug 2017 13:12:34 +0200

Two update suggestions were taken into account
from static source code analysis.

Markus Elfring (2):
  Delete an error message for a failed memory allocation
  Use common error handling code

 mm/zpool.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

-- 
2.14.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
