Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9593D6B002C
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 15:58:27 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 2so5174057pft.4
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 12:58:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b5-v6si7414429plk.567.2018.03.22.12.58.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Mar 2018 12:58:25 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 2/4] Rename 'free' functions
Date: Thu, 22 Mar 2018 12:58:17 -0700
Message-Id: <20180322195819.24271-3-willy@infradead.org>
In-Reply-To: <20180322195819.24271-1-willy@infradead.org>
References: <20180322195819.24271-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The names of these static functions collide with a kernel-wide 'free'
function.  Call them 'free_inst' instead.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 crypto/lrw.c | 4 ++--
 crypto/xts.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/crypto/lrw.c b/crypto/lrw.c
index cbbd7c50ad19..2b93fc7f4e38 100644
--- a/crypto/lrw.c
+++ b/crypto/lrw.c
@@ -522,7 +522,7 @@ static void exit_tfm(struct crypto_skcipher *tfm)
 	crypto_free_skcipher(ctx->child);
 }
 
-static void free(struct skcipher_instance *inst)
+static void free_inst(struct skcipher_instance *inst)
 {
 	crypto_drop_skcipher(skcipher_instance_ctx(inst));
 	kfree(inst);
@@ -634,7 +634,7 @@ static int create(struct crypto_template *tmpl, struct rtattr **tb)
 	inst->alg.encrypt = encrypt;
 	inst->alg.decrypt = decrypt;
 
-	inst->free = free;
+	inst->free = free_inst;
 
 	err = skcipher_register_instance(tmpl, inst);
 	if (err)
diff --git a/crypto/xts.c b/crypto/xts.c
index f317c48b5e43..5a7ac3dc2fd7 100644
--- a/crypto/xts.c
+++ b/crypto/xts.c
@@ -465,7 +465,7 @@ static void exit_tfm(struct crypto_skcipher *tfm)
 	crypto_free_cipher(ctx->tweak);
 }
 
-static void free(struct skcipher_instance *inst)
+static void free_inst(struct skcipher_instance *inst)
 {
 	crypto_drop_skcipher(skcipher_instance_ctx(inst));
 	kfree(inst);
@@ -576,7 +576,7 @@ static int create(struct crypto_template *tmpl, struct rtattr **tb)
 	inst->alg.encrypt = encrypt;
 	inst->alg.decrypt = decrypt;
 
-	inst->free = free;
+	inst->free = free_inst;
 
 	err = skcipher_register_instance(tmpl, inst);
 	if (err)
-- 
2.16.2
