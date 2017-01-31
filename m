Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 845C56B0033
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 15:38:45 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id x1so149933867lff.6
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 12:38:45 -0800 (PST)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id l137si10961469lfb.261.2017.01.31.12.38.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jan 2017 12:38:43 -0800 (PST)
Received: by mail-lf0-x241.google.com with SMTP id q89so34874420lfi.1
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 12:38:43 -0800 (PST)
Date: Tue, 31 Jan 2017 21:38:29 +0100
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH/RESEND v3 0/5] z3fold: optimizations and fixes
Message-Id: <20170131213829.3d86c07ffd1358019354c937@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>


This is a new take on z3fold optimizations/fixes consolidation, revised after comments from Dan ([1] - [6]).
The coming patches are to be applied on top of the following commit:

Author: zhong jiang <zhongjiang@huawei.com>
Date:   Tue Dec 20 11:53:40 2016 +1100

    mm/z3fold.c: limit first_num to the actual range of possible buddy indexes

All the z3fold patches newer than this one are considered obsolete and should be substituted with this patch series. The coming patches have been verified with linux-next tree.

[1] https://lkml.org/lkml/2016/11/29/969
[2] https://lkml.org/lkml/2017/1/4/586
[3] https://lkml.org/lkml/2017/1/4/604
[4] https://lkml.org/lkml/2017/1/4/737
[5] https://lkml.org/lkml/2017/1/11/514
[6] https://lkml.org/lkml/2017/1/11/552

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
