Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC2C5C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 22:14:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 492202070C
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 22:14:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="iXjwC9Y2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 492202070C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B13CF6B0003; Mon, 12 Aug 2019 18:14:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC4806B0005; Mon, 12 Aug 2019 18:14:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B2986B0006; Mon, 12 Aug 2019 18:14:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0202.hostedemail.com [216.40.44.202])
	by kanga.kvack.org (Postfix) with ESMTP id 754896B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 18:14:36 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 1B970180AD7C1
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 22:14:36 +0000 (UTC)
X-FDA: 75815180952.14.vein72_b009092e5113
X-HE-Tag: vein72_b009092e5113
X-Filterd-Recvd-Size: 12211
Received: from mail-qk1-f202.google.com (mail-qk1-f202.google.com [209.85.222.202])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 22:14:35 +0000 (UTC)
Received: by mail-qk1-f202.google.com with SMTP id n190so94664279qkd.5
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 15:14:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=YzrsGQWJ9vf69SNd20htWu1bd7T+J/M+qkSI3MhX4Ko=;
        b=iXjwC9Y27Pyh6en1ZnbDa1fykedsqhqOp1ZdMaRwYKA/BsVXNK4LjdCxOffkRdq2EA
         p4q1VdnEwfp5vDbFLEexJXk/E8jf1pXAfnuxWa7bUkgUKxKUWVIXx8futJWOKsg5tgRi
         t3ooQZ078lhn4jxx4pd7k6bEFrYpxJB1vanwsyLajRwYh9MRqaPPoUqrp0+b51qB5KWG
         5bbGA9QKKBMkyjzSjzupOYaoshw/SLswq48o083JipcVXn1lS53QSdbDbanb29/BjTB4
         Pl+Db5fwFXJs/xvuUfU7Y55JbRGSZ7WjYmHSJ7BJWzCoa3kDYU9wZg6PUxYsxS4G5HSq
         snhQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:in-reply-to:message-id:mime-version
         :references:subject:from:to:cc;
        bh=YzrsGQWJ9vf69SNd20htWu1bd7T+J/M+qkSI3MhX4Ko=;
        b=bwyq+mNsrzdHGaY8zpumYsqNExhtJZngB1eVepN4OlkpBNKCQcJelqjxGdsQlNaTLt
         5jWl/m9hVB4Xu9HjcVn270iGNwiBy6Rl4mPOexlEa7QlsqflyRbYP1OAVdEYi3AmPQoI
         vch8PnqVKrFrKQqF0/phdRNuR/cA325Pm2hYHcBvos7oH3ksg+VGsejav2+D+aX+TrA9
         lmtSNRYYTJZG4ekHECtnrnzYPfsN/o64GSg39tBRnSYdqy83WMCpdokTNcUUFIOzLTPk
         Nwxeq1f+maNxrKoVb7aipsVg6Q5zjh9eZ2tpiwTEBSEwGvz91LafWkOu1Ya0qBIz4Spp
         ze5A==
X-Gm-Message-State: APjAAAVLCvMeIpV9oIDV0cTnbaZC/MHPAF1HDZcVwfQUubP7RqVCC5XF
	MeFlACKyfa9YJOEuycxBlp80k3za/w==
X-Google-Smtp-Source: APXvYqwItN2fhw3RZGfjP0FGuB7HJ+AD1Ro7BeqFi9haqdm/rxaIb60UELBKJiM5gqgLIKQSChRdRnAO0w==
X-Received: by 2002:a05:620a:1f0:: with SMTP id x16mr20622958qkn.11.1565648074752;
 Mon, 12 Aug 2019 15:14:34 -0700 (PDT)
Date: Mon, 12 Aug 2019 15:14:16 -0700
In-Reply-To: <20190812214711.83710-1-nhuck@google.com>
Message-Id: <20190812221416.139678-1-nhuck@google.com>
Mime-Version: 1.0
References: <20190812214711.83710-1-nhuck@google.com>
X-Mailer: git-send-email 2.23.0.rc1.153.gdeed80330f-goog
Subject: [PATCH v2] kbuild: Change fallthrough comments to attributes
From: Nathan Huckleberry <nhuck@google.com>
To: yamada.masahiro@socionext.com, michal.lkml@markovi.net
Cc: linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, clang-built-linux@googlegroups.com, 
	Nathan Huckleberry <nhuck@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Clang does not support the use of comments to label
intentional fallthrough. This patch replaces some uses
of comments to attributesto cut down a significant number
of warnings on clang (from ~50000 to ~200). Only comments
in commonly used header files have been replaced.

Since there is still quite a bit of noise, this
patch moves -Wimplicit-fallthrough to
Makefile.extrawarn if you are compiling with
clang.

Signed-off-by: Nathan Huckleberry <nhuck@google.com>
---
 Makefile                            |  4 ++
 include/linux/compiler_attributes.h |  4 ++
 include/linux/jhash.h               | 60 +++++++++++++++++++++--------
 include/linux/mm.h                  |  9 +++--
 include/linux/signal.h              | 14 ++++---
 include/linux/skbuff.h              | 12 +++---
 lib/zstd/bitstream.h                | 10 ++---
 scripts/Makefile.extrawarn          |  3 ++
 8 files changed, 81 insertions(+), 35 deletions(-)

diff --git a/Makefile b/Makefile
index 1b23f95db176..93b9744e66a2 100644
--- a/Makefile
+++ b/Makefile
@@ -846,7 +846,11 @@ NOSTDINC_FLAGS += -nostdinc -isystem $(shell $(CC) -print-file-name=include)
 KBUILD_CFLAGS += -Wdeclaration-after-statement
 
 # Warn about unmarked fall-throughs in switch statement.
+# If the compiler is clang, this warning is only enabled if W=1 in
+# Makefile.extrawarn
+ifndef CONFIG_CC_IS_CLANG
 KBUILD_CFLAGS += $(call cc-option,-Wimplicit-fallthrough,)
+endif
 
 # Variable Length Arrays (VLAs) should not be used anywhere in the kernel
 KBUILD_CFLAGS += -Wvla
diff --git a/include/linux/compiler_attributes.h b/include/linux/compiler_attributes.h
index 6b318efd8a74..86c26bc0ace5 100644
--- a/include/linux/compiler_attributes.h
+++ b/include/linux/compiler_attributes.h
@@ -253,4 +253,8 @@
  */
 #define __weak                          __attribute__((__weak__))
 
+#if __has_attribute(fallthrough)
+#define __fallthrough                   __attribute__((fallthrough))
+#endif
+
 #endif /* __LINUX_COMPILER_ATTRIBUTES_H */
diff --git a/include/linux/jhash.h b/include/linux/jhash.h
index ba2f6a9776b6..1d21e3f32823 100644
--- a/include/linux/jhash.h
+++ b/include/linux/jhash.h
@@ -86,19 +86,43 @@ static inline u32 jhash(const void *key, u32 length, u32 initval)
 	}
 	/* Last block: affect all 32 bits of (c) */
 	switch (length) {
-	case 12: c += (u32)k[11]<<24;	/* fall through */
-	case 11: c += (u32)k[10]<<16;	/* fall through */
-	case 10: c += (u32)k[9]<<8;	/* fall through */
-	case 9:  c += k[8];		/* fall through */
-	case 8:  b += (u32)k[7]<<24;	/* fall through */
-	case 7:  b += (u32)k[6]<<16;	/* fall through */
-	case 6:  b += (u32)k[5]<<8;	/* fall through */
-	case 5:  b += k[4];		/* fall through */
-	case 4:  a += (u32)k[3]<<24;	/* fall through */
-	case 3:  a += (u32)k[2]<<16;	/* fall through */
-	case 2:  a += (u32)k[1]<<8;	/* fall through */
-	case 1:  a += k[0];
+	case 12:
+		c += (u32)k[11]<<24;
+		__fallthrough;
+	case 11:
+		c += (u32)k[10]<<16;
+		__fallthrough;
+	case 10:
+		c += (u32)k[9]<<8;
+		__fallthrough;
+	case 9:
+		c += k[8];
+		__fallthrough;
+	case 8:
+		b += (u32)k[7]<<24;
+		__fallthrough;
+	case 7:
+		b += (u32)k[6]<<16;
+		__fallthrough;
+	case 6:
+		b += (u32)k[5]<<8;
+		__fallthrough;
+	case 5:
+		b += k[4];
+		__fallthrough;
+	case 4:
+		a += (u32)k[3]<<24;
+		__fallthrough;
+	case 3:
+		a += (u32)k[2]<<16;
+		__fallthrough;
+	case 2:
+		a += (u32)k[1]<<8;
+		__fallthrough;
+	case 1:
+		a += k[0];
 		 __jhash_final(a, b, c);
+		break;
 	case 0: /* Nothing left to add */
 		break;
 	}
@@ -132,10 +156,16 @@ static inline u32 jhash2(const u32 *k, u32 length, u32 initval)
 
 	/* Handle the last 3 u32's */
 	switch (length) {
-	case 3: c += k[2];	/* fall through */
-	case 2: b += k[1];	/* fall through */
-	case 1: a += k[0];
+	case 3:
+		c += k[2];
+		__fallthrough;
+	case 2:
+		b += k[1];
+		__fallthrough;
+	case 1:
+		a += k[0];
 		__jhash_final(a, b, c);
+		break;
 	case 0:	/* Nothing left to add */
 		break;
 	}
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0334ca97c584..7acb131e287f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -158,11 +158,14 @@ static inline void __mm_zero_struct_page(struct page *page)
 
 	switch (sizeof(struct page)) {
 	case 80:
-		_pp[9] = 0;	/* fallthrough */
+		_pp[9] = 0;
+		__fallthrough;
 	case 72:
-		_pp[8] = 0;	/* fallthrough */
+		_pp[8] = 0;
+		__fallthrough;
 	case 64:
-		_pp[7] = 0;	/* fallthrough */
+		_pp[7] = 0;
+		__fallthrough;
 	case 56:
 		_pp[6] = 0;
 		_pp[5] = 0;
diff --git a/include/linux/signal.h b/include/linux/signal.h
index b5d99482d3fe..fb750e87566f 100644
--- a/include/linux/signal.h
+++ b/include/linux/signal.h
@@ -129,11 +129,11 @@ static inline void name(sigset_t *r, const sigset_t *a, const sigset_t *b) \
 		b3 = b->sig[3]; b2 = b->sig[2];				\
 		r->sig[3] = op(a3, b3);					\
 		r->sig[2] = op(a2, b2);					\
-		/* fall through */					\
+		__fallthrough;						\
 	case 2:								\
 		a1 = a->sig[1]; b1 = b->sig[1];				\
 		r->sig[1] = op(a1, b1);					\
-		/* fall through */					\
+		__fallthrough;						\
 	case 1:								\
 		a0 = a->sig[0]; b0 = b->sig[0];				\
 		r->sig[0] = op(a0, b0);					\
@@ -163,9 +163,9 @@ static inline void name(sigset_t *set)					\
 	switch (_NSIG_WORDS) {						\
 	case 4:	set->sig[3] = op(set->sig[3]);				\
 		set->sig[2] = op(set->sig[2]);				\
-		/* fall through */					\
+		__fallthrough;				\
 	case 2:	set->sig[1] = op(set->sig[1]);				\
-		/* fall through */					\
+		__fallthrough;				\
 	case 1:	set->sig[0] = op(set->sig[0]);				\
 		    break;						\
 	default:							\
@@ -186,7 +186,7 @@ static inline void sigemptyset(sigset_t *set)
 		memset(set, 0, sizeof(sigset_t));
 		break;
 	case 2: set->sig[1] = 0;
-		/* fall through */
+		__fallthrough;
 	case 1:	set->sig[0] = 0;
 		break;
 	}
@@ -199,7 +199,7 @@ static inline void sigfillset(sigset_t *set)
 		memset(set, -1, sizeof(sigset_t));
 		break;
 	case 2: set->sig[1] = -1;
-		/* fall through */
+		__fallthrough;
 	case 1:	set->sig[0] = -1;
 		break;
 	}
@@ -230,6 +230,7 @@ static inline void siginitset(sigset_t *set, unsigned long mask)
 		memset(&set->sig[1], 0, sizeof(long)*(_NSIG_WORDS-1));
 		break;
 	case 2: set->sig[1] = 0;
+		__fallthrough;
 	case 1: ;
 	}
 }
@@ -242,6 +243,7 @@ static inline void siginitsetinv(sigset_t *set, unsigned long mask)
 		memset(&set->sig[1], -1, sizeof(long)*(_NSIG_WORDS-1));
 		break;
 	case 2: set->sig[1] = -1;
+		__fallthrough;
 	case 1: ;
 	}
 }
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d8af86d995d6..1b7d3cf81dd8 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3639,19 +3639,19 @@ static inline bool __skb_metadata_differs(const struct sk_buff *skb_a,
 #define __it(x, op) (x -= sizeof(u##op))
 #define __it_diff(a, b, op) (*(u##op *)__it(a, op)) ^ (*(u##op *)__it(b, op))
 	case 32: diffs |= __it_diff(a, b, 64);
-		 /* fall through */
+		__fallthrough;
 	case 24: diffs |= __it_diff(a, b, 64);
-		 /* fall through */
+		__fallthrough;
 	case 16: diffs |= __it_diff(a, b, 64);
-		 /* fall through */
+		__fallthrough;
 	case  8: diffs |= __it_diff(a, b, 64);
 		break;
 	case 28: diffs |= __it_diff(a, b, 64);
-		 /* fall through */
+		__fallthrough;
 	case 20: diffs |= __it_diff(a, b, 64);
-		 /* fall through */
+		__fallthrough;
 	case 12: diffs |= __it_diff(a, b, 64);
-		 /* fall through */
+		__fallthrough;
 	case  4: diffs |= __it_diff(a, b, 32);
 		break;
 	}
diff --git a/lib/zstd/bitstream.h b/lib/zstd/bitstream.h
index 3a49784d5c61..36c9aeafd801 100644
--- a/lib/zstd/bitstream.h
+++ b/lib/zstd/bitstream.h
@@ -259,15 +259,15 @@ ZSTD_STATIC size_t BIT_initDStream(BIT_DStream_t *bitD, const void *srcBuffer, s
 		bitD->bitContainer = *(const BYTE *)(bitD->start);
 		switch (srcSize) {
 		case 7: bitD->bitContainer += (size_t)(((const BYTE *)(srcBuffer))[6]) << (sizeof(bitD->bitContainer) * 8 - 16);
-			/* fall through */
+			__fallthrough;
 		case 6: bitD->bitContainer += (size_t)(((const BYTE *)(srcBuffer))[5]) << (sizeof(bitD->bitContainer) * 8 - 24);
-			/* fall through */
+			__fallthrough;
 		case 5: bitD->bitContainer += (size_t)(((const BYTE *)(srcBuffer))[4]) << (sizeof(bitD->bitContainer) * 8 - 32);
-			/* fall through */
+			__fallthrough;
 		case 4: bitD->bitContainer += (size_t)(((const BYTE *)(srcBuffer))[3]) << 24;
-			/* fall through */
+			__fallthrough;
 		case 3: bitD->bitContainer += (size_t)(((const BYTE *)(srcBuffer))[2]) << 16;
-			/* fall through */
+			__fallthrough;
 		case 2: bitD->bitContainer += (size_t)(((const BYTE *)(srcBuffer))[1]) << 8;
 		default:;
 		}
diff --git a/scripts/Makefile.extrawarn b/scripts/Makefile.extrawarn
index a74ce2e3c33e..e12359d69bb7 100644
--- a/scripts/Makefile.extrawarn
+++ b/scripts/Makefile.extrawarn
@@ -30,6 +30,9 @@ warning-1 += $(call cc-option, -Wunused-but-set-variable)
 warning-1 += $(call cc-option, -Wunused-const-variable)
 warning-1 += $(call cc-option, -Wpacked-not-aligned)
 warning-1 += $(call cc-option, -Wstringop-truncation)
+ifdef CONFIG_CC_IS_CLANG
+KBUILD_CFLAGS += $(call cc-option,-Wimplicit-fallthrough,)
+endif
 # The following turn off the warnings enabled by -Wextra
 warning-1 += -Wno-missing-field-initializers
 warning-1 += -Wno-sign-compare
-- 
2.23.0.rc1.153.gdeed80330f-goog


