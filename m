Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3883DC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:00:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB48A218A1
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:00:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="LvDpk8rP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB48A218A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F405B8E0172; Mon, 11 Feb 2019 17:00:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF1618E0165; Mon, 11 Feb 2019 17:00:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1BEA8E0172; Mon, 11 Feb 2019 17:00:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 782978E0165
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:00:04 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id e14so161314wrt.12
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:00:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xu9/37gH7GsD7XGP+9mY66oknw0IDCzNaIitxBdfe0s=;
        b=hQWfECosfNueu3+jPMOijqgTyAIXA1rlDOGz2r8pgiPuDBL72s62y+NLgnwNQfaBqU
         ENMnL30Cg/yOaGLWuroDVMr1Sf6NfblKP6b2megPfIsGK9aLNPIIkfQY9dZjP99rY1eM
         +tEvcnaT6VknBDgvlu4tzJLsGt+nNo1XgW64GR+wzsSUeeJ2C9xl+idMuA/yyZv6R8Ps
         pZ/N737jw9EdIYKu+IvRC/29X1aUzZv+1UYzmRVaFzGHVDrx5uc3BnD/qafkyqEHqZPG
         iK8ujUY4Lf65/y2OVgpvmOy3gSWkpQICeIhSotYAkHfveGFDM9+Pu3GS5UEqkadVNWEl
         QOtg==
X-Gm-Message-State: AHQUAuZwpsmGWCj+fJS9efR5UeK/D5zW3peWsXggN8Pf8WfKUagJQvtw
	L3hwPg5d0wCU7toqXJ18Ieu/17VgJFdmbQPZrqZciX58QlXDqcpQXi9wTTyLQuMgQkC+p5OO41s
	L9coAZYYT5AtDgZ38tSPe4fa0P1ujA1gQuosnbpUPU+Krr7RmhVTgstryP5f+s1jnyiKA/kjvrk
	SEj4g+sJfLRxu7EqxT5n9SsHnle5Fnin8fLOImRWJ/jZLmcOCnvFZHUkOVMXfvbMQJwiPO/hSST
	8HX8iABF10OjW4jTF62DqCxLSgaPL0PkjM89x8o7wPo6PYzb1WHZPOfNr0GoTRSnTwCG1WXGb1K
	ZEdkP6KZYSxToT8+JgYb0LG0ic0E7+boGZwWnCfybyonQlPooTRlTvWGBAxGKYH0IZ95bM8b2lM
	e
X-Received: by 2002:adf:ed0f:: with SMTP id a15mr252353wro.249.1549922403892;
        Mon, 11 Feb 2019 14:00:03 -0800 (PST)
X-Received: by 2002:adf:ed0f:: with SMTP id a15mr252307wro.249.1549922403022;
        Mon, 11 Feb 2019 14:00:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549922403; cv=none;
        d=google.com; s=arc-20160816;
        b=cjaabVuGKxZHouMijshGN8rOdKMoJ6D7+WezXuWatquvO51N1zdivExdJ8PNUXmhdp
         xv6TKKhmDsTzsTdVKDUeW9zkhXUHepFi/CDGasimqBnBslnbjDK2SDZxCGRQoZU7l+V1
         uM+oNYg4yC2Pujb9NEfIf+9TB3Y9OHMNipBk8QjxaPFxbf7IknUCb2rNc93BajiRGLjC
         rjtagS8LvFSKYLVKwliqANaGnNE42w7qB4aKYQufkOV1L20eW0pItVzkuOODfG5gPqYI
         iff2hnBz8xuTf5TPhOOjcRhtzkThxqo8Kdfoo5U69bnRoeaRKnyiAcUJh+ushqeiaFUa
         /REw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=xu9/37gH7GsD7XGP+9mY66oknw0IDCzNaIitxBdfe0s=;
        b=rne7YWL8ILPKvT9829f0R0P2E3JoQnGlcYTOduo9MHc3CkfZqhSNt+C2FpS2J9/Dkn
         tOgXBQjwoijZDQbtPB8DkzWMR5eRxNDdk+S4rXN3aGlt+WjNC1mGvNG/7znT534DeVI6
         XIs8jlUqCYMmyxNpuAILyV6oycYRr3H0CAeRWq4LnHaa+Ml90U/QYi1UaqYI6i+Lab3D
         G5naIzhP195GG3J2Fdip6HSldOykAJUKM61/1zqltRHVsYp44tOU+11H2fl9/ROxNsO4
         /9ZJfblNPqSeb1Own6YDn+sx0p2bf+v6kvC36SZiOZNGzBNGtuZBHAOU+q7jMXtUX+tb
         yD5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LvDpk8rP;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d10sor3685006wre.27.2019.02.11.14.00.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 14:00:03 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LvDpk8rP;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=xu9/37gH7GsD7XGP+9mY66oknw0IDCzNaIitxBdfe0s=;
        b=LvDpk8rPB3n4BLRV+GWRak4fy4PQK/nUyEZdQO8ek2m2qmtOvn9x9BaisqKXQk6TIz
         kI0YBJ3nAdG50wT9X9SbBsBC6H+lZyC9ZV201ioFawASZWLGJ9ZF+JPMsO3kjK/P2lra
         SqXZnv1ATyfvt0QOyPl/Y6z1F3tocJYTZfc6Eh7eeli7zJ3RKCZRtC2r0YMrVKxi15S9
         BfIeI5BrOB0Sje8/M66uiaWc+Hy6gQbTgIL7xNVqIvtvPlFYO6wlxPqYcQA8jXC/UbWW
         xzqt8ab59GILV1YPmno+TCjFrlvUlQe1Y50UYnqEKlrgFrbPy77O/FZSbtd+zXVPxuuF
         a4mw==
X-Google-Smtp-Source: AHgI3IakbUaIb3vF6wxwPHL9o50hSBKxqinOgDtxfHR6KU/+RnrMyAuJM28Z+cs9oXYm/Eh5PEOx7A==
X-Received: by 2002:adf:e747:: with SMTP id c7mr283433wrn.176.1549922402509;
        Mon, 11 Feb 2019 14:00:02 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id c186sm762685wmf.34.2019.02.11.14.00.00
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 14:00:01 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 2/5] kasan, kmemleak: pass tagged pointers to kmemleak
Date: Mon, 11 Feb 2019 22:59:51 +0100
Message-Id: <cd825aa4897b0fc37d3316838993881daccbe9f5.1549921721.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.20.1.791.gb4d0f1c61a-goog
In-Reply-To: <cover.1549921721.git.andreyknvl@google.com>
References: <cover.1549921721.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Right now we call kmemleak hooks before assigning tags to pointers in
KASAN hooks. As a result, when an objects gets allocated, kmemleak sees
a differently tagged pointer, compared to the one it sees when the object
gets freed. Fix it by calling KASAN hooks before kmemleak's ones.

Reported-by: Qian Cai <cai@lca.pw>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/slab.h        | 6 ++----
 mm/slab_common.c | 2 +-
 mm/slub.c        | 3 ++-
 3 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/mm/slab.h b/mm/slab.h
index 4190c24ef0e9..638ea1b25d39 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -437,11 +437,9 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
 
 	flags &= gfp_allowed_mask;
 	for (i = 0; i < size; i++) {
-		void *object = p[i];
-
-		kmemleak_alloc_recursive(object, s->object_size, 1,
+		p[i] = kasan_slab_alloc(s, p[i], flags);
+		kmemleak_alloc_recursive(p[i], s->object_size, 1,
 					 s->flags, flags);
-		p[i] = kasan_slab_alloc(s, object, flags);
 	}
 
 	if (memcg_kmem_enabled())
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 81732d05e74a..fe524c8d0246 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1228,8 +1228,8 @@ void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
 	flags |= __GFP_COMP;
 	page = alloc_pages(flags, order);
 	ret = page ? page_address(page) : NULL;
-	kmemleak_alloc(ret, size, 1, flags);
 	ret = kasan_kmalloc_large(ret, size, flags);
+	kmemleak_alloc(ret, size, 1, flags);
 	return ret;
 }
 EXPORT_SYMBOL(kmalloc_order);
diff --git a/mm/slub.c b/mm/slub.c
index 1e3d0ec4e200..4a3d7686902f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1374,8 +1374,9 @@ static inline void dec_slabs_node(struct kmem_cache *s, int node,
  */
 static inline void *kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
 {
+	ptr = kasan_kmalloc_large(ptr, size, flags);
 	kmemleak_alloc(ptr, size, 1, flags);
-	return kasan_kmalloc_large(ptr, size, flags);
+	return ptr;
 }
 
 static __always_inline void kfree_hook(void *x)
-- 
2.20.1.791.gb4d0f1c61a-goog

