Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 34C026B0069
	for <linux-mm@kvack.org>; Sat, 26 Nov 2016 14:16:41 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id o20so37357379lfg.2
        for <linux-mm@kvack.org>; Sat, 26 Nov 2016 11:16:41 -0800 (PST)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id b184si23642654lfg.422.2016.11.26.11.16.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Nov 2016 11:16:39 -0800 (PST)
Received: by mail-lf0-x244.google.com with SMTP id o141so5925640lff.1
        for <linux-mm@kvack.org>; Sat, 26 Nov 2016 11:16:39 -0800 (PST)
Date: Sat, 26 Nov 2016 20:15:34 +0100
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH 0/2] z3fold fixes
Message-Id: <20161126201534.5d5e338f678b478e7a7b8dc3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Dan Carpenter <dan.carpenter@oracle.com>

Here come 2 patches with z3fold fixes for chunks counting and locking. As commit 50a50d2 ("z3fold: don't fail kernel build is z3fold_header is too big") was NAK'ed [1], I would suggest that we removed that one and the next z3fold commit cc1e9c8 ("z3fold: discourage use of pages that weren't compacted") and applied the coming 2 instead.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>

[1] https://lkml.org/lkml/2016/11/25/595

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
