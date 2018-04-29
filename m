Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4FB6B0008
	for <linux-mm@kvack.org>; Sat, 28 Apr 2018 22:46:15 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id u190-v6so1828473lff.13
        for <linux-mm@kvack.org>; Sat, 28 Apr 2018 19:46:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y17-v6sor1763ljh.32.2018.04.28.19.46.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 28 Apr 2018 19:46:13 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 2/3] Add label and license to genalloc.rst
Date: Sun, 29 Apr 2018 06:45:41 +0400
Message-Id: <20180429024542.19475-3-igor.stoppa@huawei.com>
In-Reply-To: <20180429024542.19475-1-igor.stoppa@huawei.com>
References: <20180429024542.19475-1-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org, keescook@chromium.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-security-module@vger.kernel.org
Cc: willy@infradead.org, labbott@redhat.com, linux-kernel@vger.kernel.org, igor.stoppa@huawei.com

Add SPDX license to genalloc.rst, then a label, to allow cross-referencing.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 Documentation/core-api/genalloc.rst | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/Documentation/core-api/genalloc.rst b/Documentation/core-api/genalloc.rst
index 6b38a39fab24..0b5ade832ee8 100644
--- a/Documentation/core-api/genalloc.rst
+++ b/Documentation/core-api/genalloc.rst
@@ -1,3 +1,7 @@
+.. SPDX-License-Identifier: GPL-2.0
+
+.. _genalloc:
+
 The genalloc/genpool subsystem
 ==============================
 
-- 
2.14.1
