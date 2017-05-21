Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C0B22280850
	for <linux-mm@kvack.org>; Sun, 21 May 2017 04:24:07 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y106so10936503wrb.14
        for <linux-mm@kvack.org>; Sun, 21 May 2017 01:24:07 -0700 (PDT)
Received: from mout.web.de (mout.web.de. [217.72.192.78])
        by mx.google.com with ESMTPS id 90si9575450wrg.43.2017.05.21.01.24.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 May 2017 01:24:06 -0700 (PDT)
From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/3] zswap: Adjustments for three function implementations
Message-ID: <05101843-91f6-3243-18ea-acac8e8ef6af@users.sourceforge.net>
Date: Sun, 21 May 2017 10:23:52 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 21 May 2017 10:20:03 +0200

Three update suggestions were taken into account
from static source code analysis.

Markus Elfring (3):
  Delete an error message for a failed memory allocation in zswap_pool_create()
  Improve a size determination in zswap_frontswap_init()
  Delete an error message for a failed memory allocation in zswap_dstmem_prepare()

 mm/zswap.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
