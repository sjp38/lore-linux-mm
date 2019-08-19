Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06D8EC3A5A2
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 22:09:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1C0422CE8
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 22:09:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="nyAq4FdD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1C0422CE8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 537016B0007; Mon, 19 Aug 2019 18:09:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E8896B0008; Mon, 19 Aug 2019 18:09:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3FD686B000A; Mon, 19 Aug 2019 18:09:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0031.hostedemail.com [216.40.44.31])
	by kanga.kvack.org (Postfix) with ESMTP id 204876B0007
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 18:09:36 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id B635B180AD805
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 22:09:35 +0000 (UTC)
X-FDA: 75840569910.20.corn19_53b8662ee760d
X-HE-Tag: corn19_53b8662ee760d
X-Filterd-Recvd-Size: 9399
Received: from mail-pl1-f196.google.com (mail-pl1-f196.google.com [209.85.214.196])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 22:09:35 +0000 (UTC)
Received: by mail-pl1-f196.google.com with SMTP id f19so1216863plr.3
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 15:09:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:user-agent:mime-version;
        bh=4U8tojRaKcIJnVnSgZATNOfiLncd3nw3hZsemmDG7p4=;
        b=nyAq4FdD5c3FMmHNFuPzWes0ffOcq3f7AlYtoA8ByfjnGwHLgYOAgslmW1s3BWcX9J
         2ql7WX1JyZotu20eKy5FXmvb9sTY3I4UPCgypslQKCgjSkqVdhrmhwB6K5bdbj+ZvqWc
         f0gfE6AyeKXA4B43BxwcAUlbH2YjlG3F50gPNrzMnEVTfbIRDzFKoX7pAS19xZ577iVT
         Q4+s9m2TMcdCIyjrxm+NlCgaJKtAFQdo++TsgFoxA5MerUjC/HBrvvYyxzUyC39OiktQ
         qvHs5VE0XM4sHT+s76MNF5aw69g6Z1OvJUjUyG6naNf/qZsKW4vrsZkz6Mos9XOUzCly
         7zmw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:user-agent
         :mime-version;
        bh=4U8tojRaKcIJnVnSgZATNOfiLncd3nw3hZsemmDG7p4=;
        b=Dsii+Hx6J32uXYUyprRa2x5lxO1tGvvfsrxxjGa5CMPTYC/+qisW4TvKrj7N1H/tjt
         9eUI3QXHGCKz63Tm4Xy5dLBBBoNV9M2U/8QnrWEPSh6/vhR87SwC3gY6XL4cGmDCnHWT
         HJyJ/xVJqfQVq/LiJbCxZF3XUwKtyCSiQK0s+CHD1wHQ8aCYhhm+ANCNVhRHznu26KSA
         nBxMRFDIC+pzCIm98Xn+ny2xyNVddCivX3yotTY3ocyznMcF4h1C5hfTVubgtHr1CfEl
         R8d1RdhFMPhEVDcXQAGxYYGPDQ42za43jf21VVR+DkA/blk1T2g3aB/Hh2fW5tISzW8E
         qgmQ==
X-Gm-Message-State: APjAAAWx4C9ZAhPfkn45cqToXbqorSH+eKqj+E+iK0AaODmJ4okr7pI7
	DX8eC6SI1qHidxQ5eOApQ5Gpjg==
X-Google-Smtp-Source: APXvYqyv8uu6otD6hvhmaRqTKcElwUL0Q0SvnBUpfsg5ZHDSQ83EQgXHb+krsUUz8lpyAPntgHLbLw==
X-Received: by 2002:a17:902:a58c:: with SMTP id az12mr25542981plb.129.1566252573258;
        Mon, 19 Aug 2019 15:09:33 -0700 (PDT)
Received: from [100.112.91.228] ([104.133.8.100])
        by smtp.gmail.com with ESMTPSA id ck8sm14135453pjb.25.2019.08.19.15.09.32
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 19 Aug 2019 15:09:32 -0700 (PDT)
Date: Mon, 19 Aug 2019 15:09:14 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: David Howells <dhowells@redhat.com>
cc: Al Viro <viro@zeniv.linux.org.uk>, 
    Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: tmpfs: fixups to use of the new mount API
Message-ID: <alpine.LSU.2.11.1908191503290.1253@eggly.anvils>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Several fixups to shmem_parse_param() and tmpfs use of new mount API:

mm/shmem.c manages filesystem named "tmpfs": revert "shmem" to "tmpfs"
in its mount error messages.

/sys/kernel/mm/transparent_hugepage/shmem_enabled has valid options
"deny" and "force", but they are not valid as tmpfs "huge" options.

The "size" param is an alternative to "nr_blocks", and needs to be
recognized as changing max_blocks.  And where there's ambiguity, it's
better to mention "size" than "nr_blocks" in messages, since "size" is
the variant shown in /proc/mounts.

shmem_apply_options() left ctx->mpol as the new mpol, so then it was
freed in shmem_free_fc(), and the filesystem went on to use-after-free.

shmem_parse_param() issue "tmpfs: Bad value for '%s'" messages just
like fs_parse() would, instead of a different wording.  Where config
disables "mpol" or "huge", say "tmpfs: Unsupported parameter '%s'".

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/shmem.c |   80 ++++++++++++++++++++++++++-------------------------
 1 file changed, 42 insertions(+), 38 deletions(-)

--- mmotm/mm/shmem.c	2019-08-17 11:33:16.557900238 -0700
+++ linux/mm/shmem.c	2019-08-19 13:37:29.184001050 -0700
@@ -3432,13 +3432,11 @@ static const struct fs_parameter_enum sh
 	{ Opt_huge,	"always",	SHMEM_HUGE_ALWAYS },
 	{ Opt_huge,	"within_size",	SHMEM_HUGE_WITHIN_SIZE },
 	{ Opt_huge,	"advise",	SHMEM_HUGE_ADVISE },
-	{ Opt_huge,	"deny",		SHMEM_HUGE_DENY },
-	{ Opt_huge,	"force",	SHMEM_HUGE_FORCE },
 	{}
 };
 
 const struct fs_parameter_description shmem_fs_parameters = {
-	.name		= "shmem",
+	.name		= "tmpfs",
 	.specs		= shmem_param_specs,
 	.enums		= shmem_param_enums,
 };
@@ -3448,9 +3446,9 @@ static void shmem_apply_options(struct s
 				unsigned long inodes_in_use)
 {
 	struct shmem_fs_context *ctx = fc->fs_private;
-	struct mempolicy *old = NULL;
 
-	if (test_bit(Opt_nr_blocks, &ctx->changes))
+	if (test_bit(Opt_nr_blocks, &ctx->changes) ||
+	    test_bit(Opt_size, &ctx->changes))
 		sbinfo->max_blocks = ctx->max_blocks;
 	if (test_bit(Opt_nr_inodes, &ctx->changes)) {
 		sbinfo->max_inodes = ctx->max_inodes;
@@ -3459,8 +3457,11 @@ static void shmem_apply_options(struct s
 	if (test_bit(Opt_huge, &ctx->changes))
 		sbinfo->huge = ctx->huge;
 	if (test_bit(Opt_mpol, &ctx->changes)) {
-		old = sbinfo->mpol;
-		sbinfo->mpol = ctx->mpol;
+		/*
+		 * Update sbinfo->mpol now while stat_lock is held.
+		 * Leave shmem_free_fc() to free the old mpol if any.
+		 */
+		swap(sbinfo->mpol, ctx->mpol);
 	}
 
 	if (fc->purpose != FS_CONTEXT_FOR_RECONFIGURE) {
@@ -3471,8 +3472,6 @@ static void shmem_apply_options(struct s
 		if (test_bit(Opt_mode, &ctx->changes))
 			sbinfo->mode = ctx->mode;
 	}
-
-	mpol_put(old);
 }
 
 static int shmem_parse_param(struct fs_context *fc, struct fs_parameter *param)
@@ -3498,7 +3497,7 @@ static int shmem_parse_param(struct fs_c
 			rest++;
 		}
 		if (*rest)
-			return invalf(fc, "shmem: Invalid size");
+			goto bad_value;
 		ctx->max_blocks = DIV_ROUND_UP(size, PAGE_SIZE);
 		break;
 
@@ -3506,55 +3505,59 @@ static int shmem_parse_param(struct fs_c
 		rest = param->string;
 		ctx->max_blocks = memparse(param->string, &rest);
 		if (*rest)
-			return invalf(fc, "shmem: Invalid nr_blocks");
+			goto bad_value;
 		break;
+
 	case Opt_nr_inodes:
 		rest = param->string;
 		ctx->max_inodes = memparse(param->string, &rest);
 		if (*rest)
-			return invalf(fc, "shmem: Invalid nr_inodes");
+			goto bad_value;
 		break;
+
 	case Opt_mode:
 		ctx->mode = result.uint_32 & 07777;
 		break;
+
 	case Opt_uid:
 		ctx->uid = make_kuid(current_user_ns(), result.uint_32);
 		if (!uid_valid(ctx->uid))
-			return invalf(fc, "shmem: Invalid uid");
+			goto bad_value;
 		break;
 
 	case Opt_gid:
 		ctx->gid = make_kgid(current_user_ns(), result.uint_32);
 		if (!gid_valid(ctx->gid))
-			return invalf(fc, "shmem: Invalid gid");
+			goto bad_value;
 		break;
 
 	case Opt_huge:
-#ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
-		if (!has_transparent_hugepage() &&
-		    result.uint_32 != SHMEM_HUGE_NEVER)
-			return invalf(fc, "shmem: Huge pages disabled");
-
 		ctx->huge = result.uint_32;
+		if (ctx->huge != SHMEM_HUGE_NEVER &&
+		    !(IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE) &&
+		      has_transparent_hugepage()))
+			goto unsupported_parameter;
 		break;
-#else
-		return invalf(fc, "shmem: huge= option disabled");
-#endif
-
-	case Opt_mpol: {
-#ifdef CONFIG_NUMA
-		struct mempolicy *mpol;
-		if (mpol_parse_str(param->string, &mpol))
-			return invalf(fc, "shmem: Invalid mpol=");
-		mpol_put(ctx->mpol);
-		ctx->mpol = mpol;
-#endif
-		break;
-	}
+
+	case Opt_mpol:
+		if (IS_ENABLED(CONFIG_NUMA)) {
+			struct mempolicy *mpol;
+			if (mpol_parse_str(param->string, &mpol))
+				goto bad_value;
+			mpol_put(ctx->mpol);
+			ctx->mpol = mpol;
+			break;
+		}
+		goto unsupported_parameter;
 	}
 
 	__set_bit(opt, &ctx->changes);
 	return 0;
+
+unsupported_parameter:
+	return invalf(fc, "tmpfs: Unsupported parameter '%s'", param->key);
+bad_value:
+	return invalf(fc, "tmpfs: Bad value for '%s'", param->key);
 }
 
 /*
@@ -3572,14 +3575,15 @@ static int shmem_reconfigure(struct fs_c
 	unsigned long inodes_in_use;
 
 	spin_lock(&sbinfo->stat_lock);
-	if (test_bit(Opt_nr_blocks, &ctx->changes)) {
+	if (test_bit(Opt_nr_blocks, &ctx->changes) ||
+	    test_bit(Opt_size, &ctx->changes)) {
 		if (ctx->max_blocks && !sbinfo->max_blocks) {
 			spin_unlock(&sbinfo->stat_lock);
-			return invalf(fc, "shmem: Can't retroactively limit nr_blocks");
+			return invalf(fc, "tmpfs: Cannot retroactively limit size");
 		}
 		if (percpu_counter_compare(&sbinfo->used_blocks, ctx->max_blocks) > 0) {
 			spin_unlock(&sbinfo->stat_lock);
-			return invalf(fc, "shmem: Too few blocks for current use");
+			return invalf(fc, "tmpfs: Too small a size for current use");
 		}
 	}
 
@@ -3587,11 +3591,11 @@ static int shmem_reconfigure(struct fs_c
 	if (test_bit(Opt_nr_inodes, &ctx->changes)) {
 		if (ctx->max_inodes && !sbinfo->max_inodes) {
 			spin_unlock(&sbinfo->stat_lock);
-			return invalf(fc, "shmem: Can't retroactively limit nr_inodes");
+			return invalf(fc, "tmpfs: Cannot retroactively limit inodes");
 		}
 		if (ctx->max_inodes < inodes_in_use) {
 			spin_unlock(&sbinfo->stat_lock);
-			return invalf(fc, "shmem: Too few inodes for current use");
+			return invalf(fc, "tmpfs: Too few inodes for current use");
 		}
 	}
 

