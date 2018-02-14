Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 08CEF6B0023
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 13:26:26 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id k78so5901571pfk.12
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 10:26:26 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g1-v6si256440plt.574.2018.02.14.10.26.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Feb 2018 10:26:24 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 0/2] Add kvzalloc_struct to complement kvzalloc_array
Date: Wed, 14 Feb 2018 10:26:16 -0800
Message-Id: <20180214182618.14627-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

From: Matthew Wilcox <mawilcox@microsoft.com>

We all know the perils of multiplying a value provided from userspace
by a constant and then allocating the resulting number of bytes.  That's
why we have kvmalloc_array(), so we don't have to think about it.
This solves the same problem when we embed one of these arrays in a
struct like this:

struct {
	int n;
	unsigned long array[];
};

Using kvzalloc_struct() to allocate this will save precious thinking
time and reduce the possibilities of bugs.

Matthew Wilcox (2):
  mm: Add kernel-doc for kvfree
  mm: Add kvmalloc_ab_c and kvzalloc_struct

 include/linux/mm.h | 51 +++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/util.c          | 10 ++++++++++
 2 files changed, 61 insertions(+)

-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
