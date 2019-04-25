Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E207CC282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D535206BA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D535206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08DC46B0278; Thu, 25 Apr 2019 05:59:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2C6D6B0279; Thu, 25 Apr 2019 05:59:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF7DA6B027A; Thu, 25 Apr 2019 05:59:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8FC6C6B0278
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:46 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id u14so20601064wrr.9
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=Du/uj/cd28Qr7pRRJQwOs0SgQerLJnpQKao5Hutj7cE=;
        b=KM/z8zaYzFJq0APPoapgMt7STu5G+hMK6mSn207FSVr0AYYes4alGUVypgL4EJIDCw
         r7fM302UFKjzneg07wfb17Pk70IHS2X9unpAsQw97W4XMD2ouECkgJ2N83UIvxbCx5/K
         Hm3l2WmUGQeUm1VgWN4sbOREXTfJcX2RsVn0wFp9+wRlFanYuk+XsBNh8XRvc9MP08ts
         ILJdyBht1xZyDUICK5oP4ACRP+f1ACPlk+zed78h8jVjkIsIcPcHEvJ/ucPDuEf5NuES
         pEdL5uaudN3iFMXwwNmrupcLAhfNrRkKTQ7n6jb0y47+ntLMjZI3W5nkqd2BKrMoMvSh
         ZhuQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAW3Jk4GXK3rVZWRZFvRJOoLIjLUshlL3YGwte9zZjVLZPUJ0ijZ
	lS3qGYNOAmeE7en8gsqWqq/DDoMZkBk7tfkU/jGaO4lX+TvUb5b9rALwUwKszuSJQKlotqLu6tG
	r3/Ga327GwGmAodg3JjBhkWtt7cYpgE5xt6GQO+qtO0tcjahG2Hzd+A3R0VvkQiOSkw==
X-Received: by 2002:a1c:7518:: with SMTP id o24mr2817228wmc.42.1556186386123;
        Thu, 25 Apr 2019 02:59:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzOI/dLX81SrdhJli7aCsK/ivYD7VXp3uDSYB5IZjCmlMdcyEm4x4d5iu7UU3VXPznvL110
X-Received: by 2002:a1c:7518:: with SMTP id o24mr2817186wmc.42.1556186385371;
        Thu, 25 Apr 2019 02:59:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186385; cv=none;
        d=google.com; s=arc-20160816;
        b=K8Hqa8QBSu8iJYKNC3iuQcumS+KubUVpslDpP0wczex9Pjj8HvHUUwe/08ySJlLjWy
         Wc6Hm01ZNRwiDW84oR4lOzpWGvXsMkMgFxE19k3eZyq5jlX9FWbeg/FsGRu8ppxN88ep
         4+FhMmJZI24clBWusOMCeLd9SS0CykredCn16cHQe2bkhN9FM3BQGBj4XHBbCtzhcyTv
         jE55kQo21zUypmWXizr3on4ua5UnM0FUwgYb1vk+TH9vUaOOxOgDhNBOO42ibAio+F2M
         i6AvQwCVOi+Efq+h3IFvHD7tVFapB2IDNpa1zwji8xx98fmPMbY9VXRSltiFT+ZsAtNF
         cqYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=Du/uj/cd28Qr7pRRJQwOs0SgQerLJnpQKao5Hutj7cE=;
        b=Jcb/90stK/WizTM0YwCu/OYuNX+Wj6848cS8Sl6CtrNFSEa/c/G/GWmEmjkZi/GhAf
         cehNi3S8TthKY0VeKlIfKD14EpZB/TODsZNTrcqTr2FfwTLOo3oD4Ulmqx+jlZ0I5dc7
         hBY2rueuITKfmThva4sxVWp2c1VX9JxY8PYztxSmbEwXndkXf8Y4rMEREv+ZoSdm+VI8
         K0fRq2jXcyM69yV35jiELQOw9EVuWoU2K0ALuvJI8BcAebsYgJYyjNH6vfg/y24tlbzf
         jKie62G8bXn45NwWsvSqIy1vbD3h2MMOjhsbcxFy5YEbW1Ih1zlERtJEEiFvLL/WH0bt
         vhfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id t6si10491435wri.430.2019.04.25.02.59.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJbAK-0001yx-7e; Thu, 25 Apr 2019 11:59:40 +0200
Message-Id: <20190425094803.437950229@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:45:18 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Miroslav Benes <mbenes@suse.cz>,
 Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>,
 Alexey Dobriyan <adobriyan@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 linux-mm@kvack.org, David Rientjes <rientjes@google.com>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dmitry Vyukov <dvyukov@google.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Akinobu Mita <akinobu.mita@gmail.com>, Christoph Hellwig <hch@lst.de>,
 iommu@lists.linux-foundation.org, Robin Murphy <robin.murphy@arm.com>,
 Marek Szyprowski <m.szyprowski@samsung.com>,
 Johannes Thumshirn <jthumshirn@suse.de>, David Sterba <dsterba@suse.com>,
 Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>,
 linux-btrfs@vger.kernel.org, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>,
 Daniel Vetter <daniel@ffwll.ch>, intel-gfx@lists.freedesktop.org,
 Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
 Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
 dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
 Jani Nikula <jani.nikula@linux.intel.com>,
 Rodrigo Vivi <rodrigo.vivi@intel.com>,
 Tom Zanussi <tom.zanussi@linux.intel.com>, linux-arch@vger.kernel.org
Subject: [patch V3 25/29] livepatch: Simplify stack trace retrieval
References: <20190425094453.875139013@linutronix.de>
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
Acked-by: Miroslav Benes <mbenes@suse.cz>
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


