Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id F24906B0038
	for <linux-mm@kvack.org>; Sun, 25 Dec 2016 19:30:31 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id g12so103225226lfe.5
        for <linux-mm@kvack.org>; Sun, 25 Dec 2016 16:30:31 -0800 (PST)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id k62si23849408lfe.261.2016.12.25.16.30.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Dec 2016 16:30:30 -0800 (PST)
Received: by mail-lf0-x243.google.com with SMTP id x140so9964924lfa.2
        for <linux-mm@kvack.org>; Sun, 25 Dec 2016 16:30:30 -0800 (PST)
Date: Mon, 26 Dec 2016 01:30:16 +0100
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH/RESEND 0/5] z3fold optimizations and fixes
Message-Id: <20161226013016.968004f3db024ef2111dc458@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

This is a consolidation of z3fold optimizations and fixes done so far, revised after comments from Dan [1].
The coming patches are to be applied on top of the following commit:

commit 07cfe852286d5e314f8cd19781444e12a2b6cdf3
Author: zhong jiang <zhongjiang@huawei.com>
Date:   Tue Dec 20 11:53:40 2016 +1100

    mm/z3fold.c: limit first_num to the actual range of possible buddy indexes

All the z3fold patches newer than this one are considered obsolete and should be substituted with this patch series. The coming patches have been verified with linux-next tree.

[1] https://lkml.org/lkml/2016/11/29/969

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
