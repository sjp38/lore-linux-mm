Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id B26FE6B03A3
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 10:40:54 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id t47so20410070ota.4
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 07:40:54 -0800 (PST)
Received: from mail-ot0-x243.google.com (mail-ot0-x243.google.com. [2607:f8b0:4003:c0f::243])
        by mx.google.com with ESMTPS id d188si447015oig.20.2017.02.14.07.40.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 07:40:54 -0800 (PST)
Received: by mail-ot0-x243.google.com with SMTP id l26so3864078ota.3
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 07:40:54 -0800 (PST)
From: Mahipal Challa <mahipalreddy2006@gmail.com>
Subject: [RFC PATCH v1 0/1] mm: zswap - crypto acomp/scomp support
Date: Tue, 14 Feb 2017 21:10:20 +0530
Message-Id: <1487086821-5880-1-git-send-email-Mahipal.Challa@cavium.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: herbert@gondor.apana.org.au, sjenning@redhat.com, davem@davemloft.net
Cc: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pathreya@cavium.com, vnair@cavium.com, Mahipal Challa <Mahipal.Challa@cavium.com>

Hi Seth, Herbert,

This series adds support for kernel's new crypto acomp/scomp compression &
decompression framework to zswap. We verified these changes using the 
kernel's crypto deflate-scomp, lzo-scomp modules and Cavium's ThunderX
ZIP driver (We will post the Cavium's ThunderX ZIP driver v2 patches with
acomp/scomp support soon).

Patch is on top of 'crypto-2.6' branch.

please provide your comments.

Regards,
Mahipal

Mahipal Challa (1):
  mm: zswap - Add crypto acomp/scomp framework support

 mm/zswap.c | 129 +++++++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 99 insertions(+), 30 deletions(-)

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
