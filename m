Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31024C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:18:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDB2E21741
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:18:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="YkzThGw7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDB2E21741
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E50D86B000C; Mon, 18 Mar 2019 13:18:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E009B6B000D; Mon, 18 Mar 2019 13:18:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA2C26B000E; Mon, 18 Mar 2019 13:18:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9FDD56B000D
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 13:18:05 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id d131so2058624qkc.18
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 10:18:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=LfpjTjIWpAUqgBuBr+ROlRDq3TWjVWHbA3wqyLv7Gqg=;
        b=iqjCVYn3rmor7S533PsFWGr3fM12R9dVR7gdkIwGR4dLVx1F9L1vJ0AgvVKEAJVzNp
         q30l14Kxl7r1AlbS2rXfz9XW5ZS4EyWXwx71hC4Ue7Y96+jClsdF7Ma8oY8Ob2/XbCky
         xzIYFc/wIY3YdIfFi/Q+9xdZlBH6Haw0pG/pd9tABjZs7uv4USKjEdNgy7Jt6BGlC33k
         Pnn614CPZc7fQdAy9sZdtQreNdBspcsi5dr8mFgoeMq0rEfXLOkl035WAnwKVOFiXHnV
         ZpLTstyrTTsi7C9HnQHT/koGMfod5YlEzKw0haHjRA4KFKRs/qpZcdg29/5VepwLAqVn
         SoYQ==
X-Gm-Message-State: APjAAAUQObmVfomyw3sZQ7aMfrz/vVdu9Sk7Iv1bMKio7CtrKsFCbXIt
	dGq/4Pe8l4d/LjW83JSstm43+Sb5uBcEyDZ2peD0MkArlmHvuKqsJUSAde5u3f6GNbiwb5PxU/9
	k02nQURLPYxyUpbYKWpQGZBkxaMZboDiimpohbwy6cMNdZ8ZvnVnXHmJquv8RT+0MDA==
X-Received: by 2002:a0c:d413:: with SMTP id t19mr13746233qvh.8.1552929485381;
        Mon, 18 Mar 2019 10:18:05 -0700 (PDT)
X-Received: by 2002:a0c:d413:: with SMTP id t19mr13746184qvh.8.1552929484662;
        Mon, 18 Mar 2019 10:18:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552929484; cv=none;
        d=google.com; s=arc-20160816;
        b=oKrdm2Q7kwJ/PfJYm+i5qHoBl48jxVL0PJu0RwHF2gNzbXT9CbGdv4FRuzyURucCtN
         LFiUna5SHLrCtYW+qxZmxjd2JSPmF8tdK73HOgWd4uaXKH9pS/PSS2YZWhqJu1I2WAVi
         n9mWH2NjsEdsqfLiG8sVrBCPh9IABIxdAq8EgFeExA/cOUZeWlGkerehF7CK3DTx3408
         fZdjgBRBqULkxGPDfV5FODI4w6zIENTHvkgkiojcMp23AfDe83EVnaxAahH9h7Casmba
         ptaDJ2+JAihyH9zY1035AiNaS0Do/g7pc3t46E+OIpHvqkA7Pu9CrkMnz8Zbj1kq2oHP
         AfTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=LfpjTjIWpAUqgBuBr+ROlRDq3TWjVWHbA3wqyLv7Gqg=;
        b=Wcrx+PG5KUEaRzKetwquRyvth+n7p6E9k7Ont8AkhilJ2mAX0UCsKg/hhbJJTbrY3Q
         HQGrbzh7oBgvAOEqqlcgApLytxQHCtH9+FefNYx5JTDcR2tYGg3WGo7Z5jOVOEDmgLvI
         DzV41zRkJYyTG/1IN5CnyZzr0R/Ny6mVFgze97i0vULUzSSB6ndNNwa3s4rwrxMcFbFt
         gZBRFXvcEVfcDLSTUf2AtjodTW/PudSHr8zjDVq90yO/apkpdhlplhZscINgr+JRIWuV
         YXhoXOkhShwwDj0zXqGdisGM27XswcDbsyEfAq1UVKTTyJpfGjfmN4pjZX1kaE1OIL03
         1J1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YkzThGw7;
       spf=pass (google.com: domain of 3znkpxaokcjs5i8m9tfiqgbjjbg9.7jhgdips-hhfq57f.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3zNKPXAoKCJs5I8M9TFIQGBJJBG9.7JHGDIPS-HHFQ57F.JMB@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id g57sor13175267qtc.41.2019.03.18.10.18.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 10:18:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3znkpxaokcjs5i8m9tfiqgbjjbg9.7jhgdips-hhfq57f.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YkzThGw7;
       spf=pass (google.com: domain of 3znkpxaokcjs5i8m9tfiqgbjjbg9.7jhgdips-hhfq57f.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3zNKPXAoKCJs5I8M9TFIQGBJJBG9.7JHGDIPS-HHFQ57F.JMB@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=LfpjTjIWpAUqgBuBr+ROlRDq3TWjVWHbA3wqyLv7Gqg=;
        b=YkzThGw7U5bxwuGivZfG7gXjy3sbFeGI9LQQNwpjKesMWYXA6dWvmlyTVIDVds3jdT
         99Hv46CfyNGepDjQmBrGdjnE8DmIFRJxBJqNXjHLIWC7+99xjXgyacIB4V4zSxrfGRS1
         gCdVGS/MQBILBUagjA0XfHFo8FDflJm4SJEr94PsmlNdR79rNuZTcqAgPDOmgM2h8uU1
         X27jM72pTPp4w4jfVrzQIbmq9wd3O59csXywpy8yafGddFfq57LOwhbAfJSUMg2BvGCJ
         ay4PGD3jH0Ph4L+WAj6gW2ezv9U1Ktw+Hx+TJhzvpdvgFTaZaxSZHrZdwWAc4E0uG5zJ
         mTGw==
X-Google-Smtp-Source: APXvYqwvaFpE6Rrk389WuFNgjhFYIoDJPXDJycXik4soUJpzaOpECOFFeWGr/7DmdYgwI9v4deSBDrsPhVpuummk
X-Received: by 2002:aed:3a42:: with SMTP id n60mr10517091qte.62.1552929484433;
 Mon, 18 Mar 2019 10:18:04 -0700 (PDT)
Date: Mon, 18 Mar 2019 18:17:37 +0100
In-Reply-To: <cover.1552929301.git.andreyknvl@google.com>
Message-Id: <f46caf7bea6bdbb7e50f2abedc83df13d075735c.1552929301.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552929301.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v12 05/13] mm, arm64: untag user pointers in mm/gup.c
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, 
	linux-mm@kvack.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, 
	bpf@vger.kernel.org, linux-kselftest@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

mm/gup.c provides a kernel interface that accepts user addresses and
manipulates user pages directly (for example get_user_pages, that is used
by the futex syscall). Since a user can provided tagged addresses, we need
to handle this case.

Add untagging to gup.c functions that use user addresses for vma lookups.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/gup.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/gup.c b/mm/gup.c
index f84e22685aaa..3192741e0b3a 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -686,6 +686,8 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 	if (!nr_pages)
 		return 0;
 
+	start = untagged_addr(start);
+
 	VM_BUG_ON(!!pages != !!(gup_flags & FOLL_GET));
 
 	/*
@@ -848,6 +850,8 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	struct vm_area_struct *vma;
 	vm_fault_t ret, major = 0;
 
+	address = untagged_addr(address);
+
 	if (unlocked)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
 
-- 
2.21.0.225.g810b269d1ac-goog

