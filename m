Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 140F56B0005
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 17:50:15 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id h33so770672wrh.10
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 14:50:15 -0700 (PDT)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id i8si756387wrb.299.2018.03.13.14.50.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 14:50:13 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 2/8] Add label to genalloc.rst for cross reference
Date: Tue, 13 Mar 2018 23:45:48 +0200
Message-ID: <20180313214554.28521-3-igor.stoppa@huawei.com>
In-Reply-To: <20180313214554.28521-1-igor.stoppa@huawei.com>
References: <20180313214554.28521-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, willy@infradead.org, rppt@linux.vnet.ibm.com, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

Put a label at the beginning of the genalloc.rst, to allow other
documents to cross-reference it.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 Documentation/core-api/genalloc.rst | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/Documentation/core-api/genalloc.rst b/Documentation/core-api/genalloc.rst
index 6b38a39fab24..39dba5bb7b05 100644
--- a/Documentation/core-api/genalloc.rst
+++ b/Documentation/core-api/genalloc.rst
@@ -1,3 +1,5 @@
+.. _genalloc:
+
 The genalloc/genpool subsystem
 ==============================
 
-- 
2.14.1
