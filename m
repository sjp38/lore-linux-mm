Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8117CC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4260F206B6
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4260F206B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BBE736B0288; Thu, 18 Apr 2019 05:06:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B97F96B0289; Thu, 18 Apr 2019 05:06:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A38916B028A; Thu, 18 Apr 2019 05:06:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 561076B0288
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:58 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id k17so1527434wrq.7
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=JCj0ux7ByedEKEk5YXz2OvnjUAqieqsVDG1XIhHxw0g=;
        b=XDuoJZueJGpcXkWIIgLO22vt64/s3PoOnFmpUVL/QBhjYvK8RKeIzoRF2nEFiQeY2o
         IGCJ0q9fN6+vk33L9nqzgm34CXfA+86mymf5VM106xDPobJGNTmggmovYDdEB1PRhVgb
         Pl6j+5yt1/DU7A3ycarj8gkU1NnE39c4bbciOmS/S3oRyvxe/HA7hgwqLCeSHhrZ7AnV
         PouXSUOntqFp8B/CoAz8NC7JbhFKOa8l4XLQ+v7OjLv3UIokfmTqn/D9i0VJWOki0RSc
         FcW5nBBdB9bS4WBOdHI0mU+u+MCXxyQ8wY5vMH0BwyIouO5wHC/sqXmGoRiI9LXj6DYV
         Q2Zw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVsBIuAig1H/eml7+NYe6aiJJBjgfPHKfEOk32c7ZmdUb5Zenp4
	8BObpAgyARfvZkEJo98Czlkb6qzqKbeUIZuCYqpSin/7MlwlZI7bvH+KRpjCZ3EPzbJtKczS4Gu
	E/gDZYMm3RqUI/nIaYOOXncpo1uV1+kLyTDnvWjGC930A2GDhCaoovBXFAFJNSYNNvQ==
X-Received: by 2002:a5d:658e:: with SMTP id q14mr6522684wru.52.1555578417887;
        Thu, 18 Apr 2019 02:06:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWmv/uHcZUcoV+9g4f7SC4aRBls8+W9qA/7T6zP5XJVgFtjmpZ0CkDXMLsw2UYNkzAsIfx
X-Received: by 2002:a5d:658e:: with SMTP id q14mr6522634wru.52.1555578417148;
        Thu, 18 Apr 2019 02:06:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578417; cv=none;
        d=google.com; s=arc-20160816;
        b=vpQ6Opsj4bMPpveH6AzG280HRJZa76c1Wgzg3rom2Tds5SF6M25ARbAiVI5mbat1ts
         2GxJFToX/6HviVGkuVvviFVaCmMHISBOyEkrZS9PD8J/FfeCyPBScC9AscHiW4mpzGB9
         SH+uMXod3LbsNelLGWF/AD4QxR9XIKWoRFp2BJ4F1msYcIF5eIF6WH3+t+A8dkHvkSDV
         nYJLzIuHgxWs5yQ4KqqWkWckMhAZmNcBjOVCdd3tfflKkHnrqDZKWAI/JNHjBUTn1beQ
         D0GY8AS8/OKyT7jKhgxXF4jYLZLJNWaJYW4bG7GftlQ3cAiOHh912418qmDtIb4V8KoK
         WAtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=JCj0ux7ByedEKEk5YXz2OvnjUAqieqsVDG1XIhHxw0g=;
        b=wD1NYjjDdPqtRr7bH3Wu6cT4XBht5EDfTlKRkMxvAxYqyXDj9UF+3rrA9X3BT4IXgd
         R/cJ+kNRCLZIkZZ/Gmw+spqt22GzjFPovEyARCoQi/cjxNpGFiGPakS04ncQkHh2wmTS
         9k/1uPUeTeyMp38Dvsw2B0frmKBFVZ/YeK3tZx8YmqzJr72Abdt1AHqDRnTFlyWrjoaN
         qYQMywQT+euSRyCumpk8DUyNZ7ws0fT+IwMg0Zfzy0k+YXEosNkx7C0RZSE7LSF8/xI3
         uR3WSyIeJQclIs/bBkGrMRQ9Dh1ALEobUYDD9Vo8esNULt3pm2CSXpvQxZPxACrmOXyb
         U0EQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id v6si1266619wro.213.2019.04.18.02.06.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH30P-0001xS-En; Thu, 18 Apr 2019 11:06:53 +0200
Message-Id: <20190418084255.364915116@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:44 +0200
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
Subject: [patch V2 25/29] livepatch: Simplify stack trace retrieval
References: <20190418084119.056416939@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Replace the indirection through struct stack_trace by using the storage
array based interfaces.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 kernel/livepatch/transition.c |   22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

--- a/kernel/livepatch/transition.c
+++ b/kernel/livepatch/transition.c
@@ -202,15 +202,15 @@ void klp_update_patch_state(struct task_
  * Determine whether the given stack trace includes any references to a
  * to-be-patched or to-be-unpatched function.
  */
-static int klp_check_stack_func(struct klp_func *func,
-				struct stack_trace *trace)
+static int klp_check_stack_func(struct klp_func *func, unsigned long *entries,
+				unsigned int nr_entries)
 {
 	unsigned long func_addr, func_size, address;
 	struct klp_ops *ops;
 	int i;
 
-	for (i = 0; i < trace->nr_entries; i++) {
-		address = trace->entries[i];
+	for (i = 0; i < nr_entries; i++) {
+		address = entries[i];
 
 		if (klp_target_state == KLP_UNPATCHED) {
 			 /*
@@ -254,29 +254,25 @@ static int klp_check_stack_func(struct k
 static int klp_check_stack(struct task_struct *task, char *err_buf)
 {
 	static unsigned long entries[MAX_STACK_ENTRIES];
-	struct stack_trace trace;
 	struct klp_object *obj;
 	struct klp_func *func;
-	int ret;
+	int ret, nr_entries;
 
-	trace.skip = 0;
-	trace.nr_entries = 0;
-	trace.max_entries = MAX_STACK_ENTRIES;
-	trace.entries = entries;
-	ret = save_stack_trace_tsk_reliable(task, &trace);
+	ret = stack_trace_save_tsk_reliable(task, entries, ARRAY_SIZE(entries));
 	WARN_ON_ONCE(ret == -ENOSYS);
-	if (ret) {
+	if (ret < 0) {
 		snprintf(err_buf, STACK_ERR_BUF_SIZE,
 			 "%s: %s:%d has an unreliable stack\n",
 			 __func__, task->comm, task->pid);
 		return ret;
 	}
+	nr_entries = ret;
 
 	klp_for_each_object(klp_transition_patch, obj) {
 		if (!obj->patched)
 			continue;
 		klp_for_each_func(obj, func) {
-			ret = klp_check_stack_func(func, &trace);
+			ret = klp_check_stack_func(func, entries, nr_entries);
 			if (ret) {
 				snprintf(err_buf, STACK_ERR_BUF_SIZE,
 					 "%s: %s:%d is sleeping on function %s\n",


