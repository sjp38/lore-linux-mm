Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 71A9F6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 05:34:04 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 49so7644475wrw.12
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 02:34:04 -0700 (PDT)
Received: from mout.web.de (mout.web.de. [217.72.192.78])
        by mx.google.com with ESMTPS id g42si5312806wrg.168.2017.08.14.02.34.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 02:34:03 -0700 (PDT)
From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/2] kmemleak: Adjustments for three function implementations
Message-ID: <301bc8c9-d9f6-87be-ce1d-dc614e82b45b@users.sourceforge.net>
Date: Mon, 14 Aug 2017 11:33:50 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 14 Aug 2017 11:30:22 +0200

Two update suggestions were taken into account
from static source code analysis.

Markus Elfring (2):
  Delete an error message for a failed memory allocation in two functions
  Use seq_puts() in print_unreferenced()

 mm/kmemleak.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

-- 
2.14.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
