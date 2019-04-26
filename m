Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DATE_IN_PAST_06_12,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C047EC43218
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 741AC208CB
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XKJ4fAeB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 741AC208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 703FB6B000C; Sat, 27 Apr 2019 02:43:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63AB96B000D; Sat, 27 Apr 2019 02:43:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DE5A6B000E; Sat, 27 Apr 2019 02:43:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 130EB6B000C
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:43:12 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m9so3485820pge.7
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:43:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=gMfxobg7i1AP5PQ14JM+oGjrmklNXXx9IUFM/PW54zo=;
        b=TSNETXkcIL5LN33ffyTWb2kuml3Xwsq6BVz1JxEDnv39mk2UXrfLp8WI1VgRLrPXe8
         hcHy+I/Vrk/JrcL8roCx0VmBYao+dchnGXaLWiysyJ+x+p4p+JWqccp3FHoO6vyAjDy4
         MAfHwQTsVcOLpblYjTZscxfkGktAsTMUgtHc3x13ZXPBtbFgMpLJr+nO6w/+Tkbt2nFQ
         iF+WBh7tEnOO+KShlqZ/FGdO6pWqbR6krijQP+hT2y5kM3Uj087FxxQGtV40hx3Ai/NC
         ix9OT/j7pbM0BBn0KJCY3U1EuOhv+4+DQ8S419roeqFjA/Dmz6D/ip5DxbDSmC7LRPmg
         nYXQ==
X-Gm-Message-State: APjAAAWQI9yRPgg2tMSQag3/Z8Y2Oi9XrBhjpoTzqNtEyUyM5Egcz5zz
	u0R55tmqKXN/0hvL+vad0sKmZlKhD9BwMwsS714pSBBvsdQj25t1WMBRjWDq9VvwqNkKrvLt/aK
	SRYobXgRclGEmiMy2vSjweA/E8eHQirazgv8DJS0Vao64i2zAuJkkc0t4kBDvtwN77w==
X-Received: by 2002:a17:902:778b:: with SMTP id o11mr27413285pll.333.1556347391745;
        Fri, 26 Apr 2019 23:43:11 -0700 (PDT)
X-Received: by 2002:a17:902:778b:: with SMTP id o11mr27413245pll.333.1556347390559;
        Fri, 26 Apr 2019 23:43:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556347390; cv=none;
        d=google.com; s=arc-20160816;
        b=c1iSuTMqRJdyenF6UV4EavVoZQZ9orKGTVW1MFAPX38VkLNmG7CyE5Ngb0wxfCKDEG
         mSqKSdr1NZcP0Y1t5vxdUIs5oUfwIwrVnELg9B9cNP8GiDFWcDbXYC4/RFQdd0jIl1kd
         qJ/ucBqbxZp4pZR8Ou2ls8ypkekepGRUj/xSn2vuZhgySGG1yKOim9WEMYQNFx/so3Zm
         QxMUJnnoRfes+9ObrSs5O6CBATfJhuu6ir5x37iuEIaXHCuJ7+dnTXm4vO4kx0emZEnb
         yFVmxft/vO0iyHAPIwYj5lL6+nlqhuNVfV+EbOwwcD+OwvHKKLCk14NxB0U7mLA3aEdt
         PPqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=gMfxobg7i1AP5PQ14JM+oGjrmklNXXx9IUFM/PW54zo=;
        b=Buv84Mfe0upw8tJNe3rVLCaKbMvamHxgGDnnsgSISga6Vyzn0noHBjhvXmm7PHjOyb
         MuPTxQHNX330qo0ydPA3JR0IHlFgqxMa4S/pB2HkfaqUEhNkkuT3GklUMg7lVeNk8QZu
         KEdZcEFnbMDtu5iNIEt9EPsTR4KV6AVWryLkmbXnf8Ye09fdRZa23ymUJhL0S0XPfeYu
         lsRqhv8JmSgwEAyqrzDCbaBxEgbStfcYh8QCFJsK/7gO9Kw9kbPYtByyNrWdFhXOkVY0
         tLXlPSfISVvxzLyz2qi6Rr0E2t9Phqb6XKbLd7PBlUHuQ2+8jvzpeFjo0IdUEz0Rhqb6
         gOiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XKJ4fAeB;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s6sor18562958plq.62.2019.04.26.23.43.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 23:43:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XKJ4fAeB;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=gMfxobg7i1AP5PQ14JM+oGjrmklNXXx9IUFM/PW54zo=;
        b=XKJ4fAeBY8aGdbJDn84dW83HzgSvQACPuhXWJHvF1CWt6rAKSo0+tUCXqeDEYn8KGx
         u3zXII+RSuYhdLmlbo5/0feDTgEEs6/tOmzti0w5Pevv/8Nua7dmelg2Hg1YTOM0HPNp
         IuB1XxBtPV5C1LDrt4HWOamCYTjBpu9Uc9bqXu6wh2x58Sr/Usj1f74P/vpY9jMFSCFS
         THBbi+fo5P15SNYnnZLc+khNDUp7StdyPifYfNcqKpXcU/HGBdU106YbtBqZ2gBNSvKt
         YTZSQ/QqPm8CwczIhg2BokKOhThemqJ36d1wwJl1ZB93G6rLPD545DygLOMnvs67gNXF
         w1Rg==
X-Google-Smtp-Source: APXvYqwk9lLXQyc9bNgKLLm6YtZMcI1PVJ4KR2rM1C+cN3nT9zotDQcbIXGbwEvAmUupbSpfYScE8w==
X-Received: by 2002:a17:902:a7:: with SMTP id a36mr50206141pla.111.1556347390037;
        Fri, 26 Apr 2019 23:43:10 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id j22sm36460145pfn.129.2019.04.26.23.43.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:43:09 -0700 (PDT)
From: nadav.amit@gmail.com
To: Peter Zijlstra <peterz@infradead.org>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	will.deacon@arm.com,
	ard.biesheuvel@linaro.org,
	kristen@linux.intel.com,
	deneen.t.dock@intel.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Nadav Amit <namit@vmware.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH v6 05/24] uprobes: Initialize uprobes earlier
Date: Fri, 26 Apr 2019 16:22:44 -0700
Message-Id: <20190426232303.28381-6-nadav.amit@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

In order to have a separate address space for text poking, we need to
duplicate init_mm early during start_kernel(). This, however, introduces
a problem since uprobes functions are called from dup_mmap(), but
uprobes is still not initialized in this early stage.

Since uprobes initialization is necassary for fork, and since all the
dependant initialization has been done when fork is initialized (percpu
and vmalloc), move uprobes initialization to fork_init(). It does not
seem uprobes introduces any security problem for the poking_mm.

Crash and burn if uprobes initialization fails, similarly to other early
initializations. Change the init_probes() name to probes_init() to match
other early initialization functions name convention.

Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Reported-by: kernel test robot <lkp@intel.com>
Signed-off-by: Nadav Amit <namit@vmware.com>
---
 include/linux/uprobes.h | 5 +++++
 kernel/events/uprobes.c | 8 +++-----
 kernel/fork.c           | 1 +
 3 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 103a48a48872..12bf0b68ed92 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -115,6 +115,7 @@ struct uprobes_state {
 	struct xol_area		*xol_area;
 };
 
+extern void __init uprobes_init(void);
 extern int set_swbp(struct arch_uprobe *aup, struct mm_struct *mm, unsigned long vaddr);
 extern int set_orig_insn(struct arch_uprobe *aup, struct mm_struct *mm, unsigned long vaddr);
 extern bool is_swbp_insn(uprobe_opcode_t *insn);
@@ -154,6 +155,10 @@ extern void arch_uprobe_copy_ixol(struct page *page, unsigned long vaddr,
 struct uprobes_state {
 };
 
+static inline void uprobes_init(void)
+{
+}
+
 #define uprobe_get_trap_addr(regs)	instruction_pointer(regs)
 
 static inline int
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index c5cde87329c7..e6a0d6be87e3 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -2294,16 +2294,14 @@ static struct notifier_block uprobe_exception_nb = {
 	.priority		= INT_MAX-1,	/* notified after kprobes, kgdb */
 };
 
-static int __init init_uprobes(void)
+void __init uprobes_init(void)
 {
 	int i;
 
 	for (i = 0; i < UPROBES_HASH_SZ; i++)
 		mutex_init(&uprobes_mmap_mutex[i]);
 
-	if (percpu_init_rwsem(&dup_mmap_sem))
-		return -ENOMEM;
+	BUG_ON(percpu_init_rwsem(&dup_mmap_sem));
 
-	return register_die_notifier(&uprobe_exception_nb);
+	BUG_ON(register_die_notifier(&uprobe_exception_nb));
 }
-__initcall(init_uprobes);
diff --git a/kernel/fork.c b/kernel/fork.c
index 9dcd18aa210b..44fba5e5e916 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -815,6 +815,7 @@ void __init fork_init(void)
 #endif
 
 	lockdep_init_task(&init_task);
+	uprobes_init();
 }
 
 int __weak arch_dup_task_struct(struct task_struct *dst,
-- 
2.17.1

