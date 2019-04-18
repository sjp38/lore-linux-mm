Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01B4FC10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5D3D2183E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5D3D2183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7DEC6B0271; Thu, 18 Apr 2019 05:06:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2FED6B0272; Thu, 18 Apr 2019 05:06:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1E3C6B0273; Thu, 18 Apr 2019 05:06:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 806D16B0271
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:27 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id y189so1536476wmd.4
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=BUnZ/ks7/6dECieHXMrPx4NPCWL205Gf+OSamdw8cq0=;
        b=Xu8+p0T+VXfSCO/dJeoc+OauWPLXWwmdLKudC4qrL56m5qJwErV6UpuCSDJgxZySy4
         BODVtogqhTRwYOGPlr3C+OQzxQPiOhUyQN6BelQ8e0xi5IWMYEf//cpP8qGZfNqKMKFq
         ClmoJdxrlKY+vPtRgQEJmt1LchdGVp9oXTxB/uXD4sbmOwj4JlJKP5INSQqgpUmTdCe/
         o21qv0wHM6/VqBfv1Qgod6b0Np9uu+yZgu0j0bUCj+RBye6l3w423Ghibx2OnE10DcBK
         cr1u14GQMt1q7T32bbMGCQsucdDDK9mW21ld7++z9c0KMnPxrqrTRZJlpU55ro24Njwi
         fSPQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAULvX9n43XEOzVvxsIg/MRxbV2bT7iemYqQ8K5UZTW4tBo8pnEc
	zyvlL76xRh56YeSK562oIwLURcgSlECF/Qv7nhsa3YhZCR45Hhj6cAE9wZhqve+jObHMeti2oqp
	tLS3pNMxWo+l8QDh9XsM5ETPd4Cq4eeA+Q4xZ3FTuo1H7/76T9wOw4Fo4GLwUAnFI6w==
X-Received: by 2002:a5d:634c:: with SMTP id b12mr37029841wrw.203.1555578386981;
        Thu, 18 Apr 2019 02:06:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzh4B1ZxVckSsU/YJ11mcVBMHyQaOan9SvVvsJKziE7l8eHbvpi4oFCLImjoPAcZ4F/N0qZ
X-Received: by 2002:a5d:634c:: with SMTP id b12mr37029788wrw.203.1555578386273;
        Thu, 18 Apr 2019 02:06:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578386; cv=none;
        d=google.com; s=arc-20160816;
        b=pWWse/u/M2NXi4pPAVbFph7U7hNVZ9ZnzvUBQfh3zUKSMTSauOnX5+HpNrVs/Pys9s
         ddkbpaHyqPB7ijYiLw2OJ5dGgbGHRY2If6/o/0n0f7xni7ciCcJoUxfZ7qFYb4p9PM6w
         mq6X1gemXVvgCA8VRglpxr/eLgTdS8N2JkM8JuNjgLX839OMTWo7pwSTvFcsVrZUUVP/
         JqFzTyCOsIyoo298vGmKWyB6B9C3U7wKPXlZzf9SfcOxjb+sETMVIiQvLw4UTs6fHMT7
         VEbq+ssCfmUnojpxMiqKDV4tJdCl1XMcHpbVoKWVYq2th/8Zn7CUokJjtFIbGOtZMLvv
         5faw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=BUnZ/ks7/6dECieHXMrPx4NPCWL205Gf+OSamdw8cq0=;
        b=KJolh1QHWW5sMm909X8Byo/bZtKJDtCaMNnD0tVkEfOvWq98V9zkPCUmzulHEq0YHv
         piTUnFkV8sSbL+7h0XPE/0q2zssEeqLYgScMq4/KIQlZVrXsatujD9HozkQYmxTDkw/Z
         v5lcBktrciJPJdxV+UdJ1tkaWbWMstdXsqpk9Xvxnorul/UP8752Lhcyp+vEaaHPW7Xc
         B+w80OnRh0V6PhqaJy4bTj6i6ydkUeL6Qbm9PqvE767dN/wvciUjbCAf5Ka7/Ol4IzfN
         +47jKekxj1Yr/ekoq3PMRZu4jOkj+wybIEywpv5fxx7OH7tk4H9IdqqWCvGK6VFpgBxP
         V3bA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id w7si1254912wru.51.2019.04.18.02.06.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:26 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH2zt-0001ox-KZ; Thu, 18 Apr 2019 11:06:21 +0200
Message-Id: <20190418084254.082820685@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:30 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>,
 Akinobu Mita <akinobu.mita@gmail.com>,
 Alexey Dobriyan <adobriyan@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org,
 David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dmitry Vyukov <dvyukov@google.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com,
 Mike Rapoport <rppt@linux.vnet.ibm.com>, iommu@lists.linux-foundation.org,
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
Subject: [patch V2 11/29] fault-inject: Simplify stacktrace retrieval
References: <20190418084119.056416939@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Replace the indirection through struct stack_trace with an invocation of
the storage array based interface.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Akinobu Mita <akinobu.mita@gmail.com>
---
 lib/fault-inject.c |   12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

--- a/lib/fault-inject.c
+++ b/lib/fault-inject.c
@@ -65,22 +65,16 @@ static bool fail_task(struct fault_attr
 
 static bool fail_stacktrace(struct fault_attr *attr)
 {
-	struct stack_trace trace;
 	int depth = attr->stacktrace_depth;
 	unsigned long entries[MAX_STACK_TRACE_DEPTH];
-	int n;
+	int n, nr_entries;
 	bool found = (attr->require_start == 0 && attr->require_end == ULONG_MAX);
 
 	if (depth == 0)
 		return found;
 
-	trace.nr_entries = 0;
-	trace.entries = entries;
-	trace.max_entries = depth;
-	trace.skip = 1;
-
-	save_stack_trace(&trace);
-	for (n = 0; n < trace.nr_entries; n++) {
+	nr_entries = stack_trace_save(entries, depth, 1);
+	for (n = 0; n < nr_entries; n++) {
 		if (attr->reject_start <= entries[n] &&
 			       entries[n] < attr->reject_end)
 			return false;


