Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 844756B14A3
	for <linux-mm@kvack.org>; Sun, 18 Nov 2018 07:13:24 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 129-v6so23163754pfx.11
        for <linux-mm@kvack.org>; Sun, 18 Nov 2018 04:13:24 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o19si15703032pfi.261.2018.11.18.04.13.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 18 Nov 2018 04:13:23 -0800 (PST)
Date: Sun, 18 Nov 2018 04:13:18 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm/filemap.c: minor optimization in write_iter file
 operation
Message-ID: <20181118121318.GC7861@bombadil.infradead.org>
References: <1542542538-11938-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1542542538-11938-1-git-send-email-laoar.shao@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: akpm@linux-foundation.org, darrick.wong@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Nov 18, 2018 at 08:02:18PM +0800, Yafang Shao wrote:
> This little adjustment on bitwise operation could make the code a little
> faster.
> As write_iter is used in lots of critical path, so this code change is
> useful for performance.

Did you check the before/after code generation with this patch applied?

$ diff -u before.S after.S
--- before.S	2018-11-18 07:11:48.031096768 -0500
+++ after.S	2018-11-18 07:11:36.883069103 -0500
@@ -1,5 +1,5 @@
 
-before.o:     file format elf32-i386
+after.o:     file format elf32-i386
 
 
 Disassembly of section .text:

with gcc 8.2.0, I see no difference, indicating that the compiler already
makes this optimisation.
