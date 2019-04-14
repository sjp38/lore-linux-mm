Return-Path: <SRS0=+oA7=SQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9F93C10F13
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 16:02:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6828420896
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 16:02:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6828420896
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE7CA6B0005; Sun, 14 Apr 2019 12:02:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6E2D6B0006; Sun, 14 Apr 2019 12:02:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B36B86B0007; Sun, 14 Apr 2019 12:02:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 620266B0005
	for <linux-mm@kvack.org>; Sun, 14 Apr 2019 12:02:19 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id k4so12877485wrw.11
        for <linux-mm@kvack.org>; Sun, 14 Apr 2019 09:02:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=xwVK6GD0cu7GHolarq4s8MkoH/FdplnDmfqbdYeKej0=;
        b=mo9DJZjXzJmKC8SLIGvtoN/p2D5/WWCnVtL0r1jJGgLbmJHOReoBd3M5h+aWN9RG9I
         Ui1rfQeM39XZNVO+zuX3bywV+ZEsC5vT+K2JRH4tf8Jiqqe4AmHMvHPJ5yNzUrAOXLAY
         REoWN9F0wVPnlshKGRB9+lomOpaTRp5HUEIUP5V4L4cQ48Zrn0GrRdM/W5GzSGDlTLfP
         ckfhTaKLy6Y3/n0PQhgvFgDAQgDP0ZU5T7EuVNwuufCMBqdsKDiR7o5eqIR74jpZzXGa
         jw6R3GFVwbYFO/UFAdoGUll5wtmFTkdSvASLHg2fX8mD3pCi6irb1TOwesgjBTjM0yPl
         HuKg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVa5rIo7ezZMHkWcXLInKA765hMJhtkrXgPdaoek5p9dZEGMhxA
	RACQli0pDCKecTCbnp9RB/CF0BIWqD43B9nvGjzaK8Rny9/5FXbW1QoBQzWj6GDv9JmzSolGLCv
	fFJvzW7O+8fZEG7zNcSPno6F5sOVVbuAusdqVNRcpW+YJRZoaMV/eXzSwNddkcpi9Ig==
X-Received: by 2002:adf:dd82:: with SMTP id x2mr3865264wrl.214.1555257738775;
        Sun, 14 Apr 2019 09:02:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrz5TFIsG4YGZXbvxqe8dGrinI3CEReg2T9Bs2o0vAJC0L08LCFYyWHwRbux7ShM+Yweip
X-Received: by 2002:adf:dd82:: with SMTP id x2mr3865227wrl.214.1555257737826;
        Sun, 14 Apr 2019 09:02:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555257737; cv=none;
        d=google.com; s=arc-20160816;
        b=f04LH0iwbV27RYdAvXW6wE9BH8jInWN1cRk/SiN5P+gwF3L5uolWFsJZ0X+07YdjQi
         iXi5MR3D6q/qi7DVMJGG9Bwtsx+EyrW/ybxhb5rGxYfobEEUNzhb8EY615MoLsWPlFsB
         rP6B9reFNXa2OhWwHpK91hqIN96Jv+3sgqFHmeGF8gDSizvQF3ImRyCDz/3KR/wOwnxe
         D2pg/Hf1X9DkQdlk7Szdw+9th3K9iOtm8X/c0VsYR6hYffgNE0LP711/TEDoaNzDFPn9
         HyDPJyNw1SdTA+/oMlx7zO14NljGKMk6ISZnsAOe3zUF+izChJ6ot61ZNuFQE/TREAMJ
         7ufg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=xwVK6GD0cu7GHolarq4s8MkoH/FdplnDmfqbdYeKej0=;
        b=MV3OnJIREuK1ORDg1muXJ6pLErFh8QHLWAqO2rTm135PXMKwiW8R0dzplDbpZOdAu8
         VFyLlnINuPzleZAoBZA0NowHJKfTlxS8w+8U+hm3wHcVKOQmmBM6coVzVjImGOu9G7Vq
         VNbfKia/SOiDosLkq/EySqcMR8u14em4QMMVHNb0axZeTrwwFQEAQEbp+EWcW5vfZSlw
         04j1UbFIBgQaJFX15fWQtkNErf9O6XkZWbivXxIzECS0t1UuJ6I1MPVxqpycqfCnH/qX
         tU97Woblf4JjIB2pHeOti2vFKBbvRBZbtabE/dRQPepF7qjncWwBdtYRDjnuQzURWkvP
         T8rg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id x25si9071683wmk.189.2019.04.14.09.02.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 14 Apr 2019 09:02:17 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hFha9-0002Y6-0B; Sun, 14 Apr 2019 18:02:13 +0200
Message-Id: <20190414160143.591255977@linutronix.de>
User-Agent: quilt/0.65
Date: Sun, 14 Apr 2019 17:59:37 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Andy Lutomirski <luto@kernel.org>,
 Josh Poimboeuf <jpoimboe@redhat.com>,
 Sean Christopherson <sean.j.christopherson@intel.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org
Subject: [patch V3 01/32] mm/slab: Fix broken stack trace storage
References: <20190414155936.679808307@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

kstack_end() is broken on interrupt stacks as they are not guaranteed to be
sized THREAD_SIZE and THREAD_SIZE aligned.

Use the stack tracer instead. Remove the pointless pointer increment at the
end of the function while at it.

Fixes: 98eb235b7feb ("[PATCH] page unmapping debug") - History tree
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org
---
 mm/slab.c |   28 ++++++++++++----------------
 1 file changed, 12 insertions(+), 16 deletions(-)

--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1470,33 +1470,29 @@ static bool is_debug_pagealloc_cache(str
 static void store_stackinfo(struct kmem_cache *cachep, unsigned long *addr,
 			    unsigned long caller)
 {
-	int size = cachep->object_size;
+	int size = cachep->object_size / sizeof(unsigned long);
 
 	addr = (unsigned long *)&((char *)addr)[obj_offset(cachep)];
 
-	if (size < 5 * sizeof(unsigned long))
+	if (size < 5)
 		return;
 
 	*addr++ = 0x12345678;
 	*addr++ = caller;
 	*addr++ = smp_processor_id();
-	size -= 3 * sizeof(unsigned long);
+#ifdef CONFIG_STACKTRACE
 	{
-		unsigned long *sptr = &caller;
-		unsigned long svalue;
-
-		while (!kstack_end(sptr)) {
-			svalue = *sptr++;
-			if (kernel_text_address(svalue)) {
-				*addr++ = svalue;
-				size -= sizeof(unsigned long);
-				if (size <= sizeof(unsigned long))
-					break;
-			}
-		}
+		struct stack_trace trace = {
+			.max_entries	= size - 4;
+			.entries	= addr;
+			.skip		= 3;
+		};
 
+		save_stack_trace(&trace);
+		addr += trace.nr_entries;
 	}
-	*addr++ = 0x87654321;
+#endif
+	*addr = 0x87654321;
 }
 
 static void slab_kernel_map(struct kmem_cache *cachep, void *objp,


