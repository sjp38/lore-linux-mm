Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08BCEC10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBE462183E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBE462183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0DB16B0279; Thu, 18 Apr 2019 05:06:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D92E16B027A; Thu, 18 Apr 2019 05:06:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0DCD6B027B; Thu, 18 Apr 2019 05:06:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6C9F76B0279
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:42 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id o16so1522563wrp.8
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=L604RDNDUsLtrdMvm5f1LPj2+7anAgRuVAW4n/LwM/A=;
        b=IU4cztcda3WBlFlw1joVtNF5wNllEkzIh291/fVO9An4TTF5rjiGUDDyj3QaCMaFXz
         F04mtHGUjSGKxayNvc2YynsJaXpu5NbomqpBRZfisUcRGRkWgWA93nefvG05hLXqKYMG
         gxXWzG4oiWhYIhI98MXG3wy0gdiyBis+BncmphoLUE5dwtTihsVFH6KuHfTgLwZyDm2r
         3g79F7w6dWNaQgBtho5MB4Ha6npexxIsuhROhL7tGQ+RYlC9QVEFW+RKtYjHTKkn6D83
         8IEZqdkC2TjfJ+RjZfEu39beQLHYScVEgzBHHboJsAYGoUQ0unEHdPH4tzkre24HAWnk
         iUxw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAXBxUzxfqBouTljkJ6+snYgPLWF7t0pJPm4G+byfVjgzofNYCTq
	izcSwgAQofmbTQV7lwQtkD02klIxlv53/+kzfXLJbjwGwRuDWnrGDR+ftTU/A3AGSFmgnvtx3ub
	+tjatmZUMpD9WCC41M5Xar45VqrdN1NMk6yug1aZUmjBjD6/oxVNy+DRM0HTwWv5ZvA==
X-Received: by 2002:a1c:4844:: with SMTP id v65mr2199874wma.139.1555578401853;
        Thu, 18 Apr 2019 02:06:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrns+ZOQca+6QkSxf/SThso4L9L/TZMqTqwhuOthfFv58D1bM7lnxDx65STrzozQZq3Rmn
X-Received: by 2002:a1c:4844:: with SMTP id v65mr2199812wma.139.1555578400908;
        Thu, 18 Apr 2019 02:06:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578400; cv=none;
        d=google.com; s=arc-20160816;
        b=S0R6kGTAKDnjoe2Hly4bTx572vjgs2emSqgyw8w/NlQA80M8oBukNANUjonHNZ5VCI
         pvUWAVqQsl6YhMZv5P9P2lYHCF1kdqhNVHJoiBrMDDhfh3a3F4HJqz0UMfbufwK10KC3
         4tWjoCyOUL47LxMWk+71QrP5JKCLVlnY4VikPd6kF923o1WrnIia7/yuHARjl2VbMR4L
         YSOoe3MKITIsT/0OSaLioRzU8Kdi7mIf2i7WIqak8d7+4wAc5m8oQuzq9j3di6xaic5y
         FaJaATep9A+bvKE4FKlbbkg++0ViOJLVFIOACfAUVryDTZywJkAM3xpqJy0S4EJmrBxO
         e7jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=L604RDNDUsLtrdMvm5f1LPj2+7anAgRuVAW4n/LwM/A=;
        b=ftNjoqRnSzkDu/HIgl8cfjR236UWRzOnEG8O2e6QjXFeApB0qi7Y9E/r1YwQRxdjgt
         ujFWhIyh34YOii+NC+6Cy1ZMl/eLYnyakK85hFHdQbOY8U3IWAcpoHNRRZw9iKquFxdy
         ehbZ6AMnarWNFkoonR3D1jSbfUMHokXNzea0Ctw04owER27Bio3m4NWYwXzhOUobb4GZ
         sHjnl4u2jw0rQB088AR3yV5fWzFGJpUPuBFEkMwAMThtFL3M3Xa52bfotGRMgAkoTtI0
         5gyN0dO5D7vqdYxse3XVqULs+mKla081JWUYL889fCDX/SzPD06BY3AKOluaJ7GBJB8W
         xqoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id z186si1171505wmb.5.2019.04.18.02.06.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH309-0001su-Qw; Thu, 18 Apr 2019 11:06:38 +0200
Message-Id: <20190418084254.729689921@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:37 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>,
 Alexey Dobriyan <adobriyan@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org,
 David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dmitry Vyukov <dvyukov@google.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Akinobu Mita <akinobu.mita@gmail.com>, iommu@lists.linux-foundation.org,
 Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>,
 Marek Szyprowski <m.szyprowski@samsung.com>,
 Johannes Thumshirn <jthumshirn@suse.de>, David Sterba <dsterba@suse.com>,
 Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>,
 linux-btrfs@vger.kernel.org, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>,
 intel-gfx@lists.freedesktop.org,
 Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
 Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
 dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
 Jani Nikula <jani.nikula@linux.intel.com>, Daniel Vetter <daniel@ffwll.ch>,
 Rodrigo Vivi <rodrigo.vivi@intel.com>, linux-arch@vger.kernel.org
Subject: [patch V2 18/29] lockdep: Move stack trace logic into check_prev_add()
References: <20190418084119.056416939@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There is only one caller of check_prev_add() which hands in a zeroed struct
stack trace and a function pointer to save_stack(). Inside check_prev_add()
the stack_trace struct is checked for being empty, which is always
true. Based on that one code path stores a stack trace which is unused. The
comment there does not make sense either. It's all leftovers from
historical lockdep code (cross release).

Move the variable into check_prev_add() itself and cleanup the nonsensical
checks and the pointless stack trace recording.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 kernel/locking/lockdep.c |   30 ++++++++----------------------
 1 file changed, 8 insertions(+), 22 deletions(-)

--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -2158,10 +2158,10 @@ check_deadlock(struct task_struct *curr,
  */
 static int
 check_prev_add(struct task_struct *curr, struct held_lock *prev,
-	       struct held_lock *next, int distance, struct stack_trace *trace,
-	       int (*save)(struct stack_trace *trace))
+	       struct held_lock *next, int distance)
 {
 	struct lock_list *uninitialized_var(target_entry);
+	struct stack_trace trace;
 	struct lock_list *entry;
 	struct lock_list this;
 	int ret;
@@ -2196,17 +2196,8 @@ check_prev_add(struct task_struct *curr,
 	this.class = hlock_class(next);
 	this.parent = NULL;
 	ret = check_noncircular(&this, hlock_class(prev), &target_entry);
-	if (unlikely(!ret)) {
-		if (!trace->entries) {
-			/*
-			 * If @save fails here, the printing might trigger
-			 * a WARN but because of the !nr_entries it should
-			 * not do bad things.
-			 */
-			save(trace);
-		}
+	if (unlikely(!ret))
 		return print_circular_bug(&this, target_entry, next, prev);
-	}
 	else if (unlikely(ret < 0))
 		return print_bfs_bug(ret);
 
@@ -2253,7 +2244,7 @@ check_prev_add(struct task_struct *curr,
 		return print_bfs_bug(ret);
 
 
-	if (!trace->entries && !save(trace))
+	if (!save_trace(&trace))
 		return 0;
 
 	/*
@@ -2262,14 +2253,14 @@ check_prev_add(struct task_struct *curr,
 	 */
 	ret = add_lock_to_list(hlock_class(next), hlock_class(prev),
 			       &hlock_class(prev)->locks_after,
-			       next->acquire_ip, distance, trace);
+			       next->acquire_ip, distance, &trace);
 
 	if (!ret)
 		return 0;
 
 	ret = add_lock_to_list(hlock_class(prev), hlock_class(next),
 			       &hlock_class(next)->locks_before,
-			       next->acquire_ip, distance, trace);
+			       next->acquire_ip, distance, &trace);
 	if (!ret)
 		return 0;
 
@@ -2287,12 +2278,6 @@ check_prevs_add(struct task_struct *curr
 {
 	int depth = curr->lockdep_depth;
 	struct held_lock *hlock;
-	struct stack_trace trace = {
-		.nr_entries = 0,
-		.max_entries = 0,
-		.entries = NULL,
-		.skip = 0,
-	};
 
 	/*
 	 * Debugging checks.
@@ -2318,7 +2303,8 @@ check_prevs_add(struct task_struct *curr
 		 * added:
 		 */
 		if (hlock->read != 2 && hlock->check) {
-			int ret = check_prev_add(curr, hlock, next, distance, &trace, save_trace);
+			int ret = check_prev_add(curr, hlock, next, distance);
+
 			if (!ret)
 				return 0;
 


