Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6A7DC6B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 01:05:00 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o124so314112029pfg.1
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 22:05:00 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id e8si1038248pfg.248.2016.08.01.22.04.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 22:04:59 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [PATCH] mm/memblock.c: fix NULL dereference error
Message-ID: <57A029A9.6060303@zoho.com>
Date: Tue, 2 Aug 2016 13:03:37 +0800
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090206090703080007050006"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: ard.biesheuvel@linaro.org, david@gibson.dropbear.id.au, dev@g0hl1n.net, kuleshovmail@gmail.com, tangchen@cn.fujitsu.com, tj@kernel.org, weiyang@linux.vnet.ibm.com, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org

This is a multi-part message in MIME format.
--------------090206090703080007050006
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

Hi Andrew,

this patch is part of https://lkml.org/lkml/2016/7/26/347 and isn't merged in
as you advised in another mail, i release this patch against linus's mainline
for fixing relevant bugs completely, see test patch attached for verification
details
--------------090206090703080007050006--
