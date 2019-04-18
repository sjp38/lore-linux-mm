Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F021C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CEE98206B6
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CEE98206B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF1616B028B; Thu, 18 Apr 2019 05:07:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA3976B028D; Thu, 18 Apr 2019 05:07:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DBC396B028E; Thu, 18 Apr 2019 05:07:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7C09B6B028B
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:07:00 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id 187so5788488wmc.1
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:07:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=NV6JAa7wwuylvkaEkDT0w0mvqeqkCtkC066wzQ8DD70=;
        b=NzXElwI4nH3wLJ1Cj5cjWKKb4qMxhl6u72pII4XBMvgBMNEG+zcQr2MG7wBNAyPUXb
         hxE69K0jUByRg0LOjuGufz+3Uq8WTbT6tvdNzQdXHgAC8E1MHIv6b3T3Lqzd04BL1rnW
         eXE9CXTXSyJ44kLC/tQyj5e4NoAuYQVeH+pjswTGkyjT7KgTuH6euuRJWHRRb3Fn/ytj
         S8h/X+VD43WIYdHzl+ou1DGNVKhIiN3z/oPAf6GzcIrVMkZolggHhi4846HUu+4+7nCM
         CMy9yR1/Hdffo4gCuwJDXfiFUabNlz0NGXq9SkOTzxH7p93M1AAmrNlE4MmZfj0hsB3W
         VTHQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAX+oRgu6F6EQEzwNbHGAVgdOfGP3WcuJ4k/cOKdePJo3TkOHxG+
	kMq3Ni0qeGoUeuW8nxqdr2K7KCkYyQbyquzrgsJKUxPaODAo7c/NEQp/iq2RG6CBDbPdHFRuhrL
	95N6kaN3cS+eJMude8JM9QEhU2lCttMGmNpjzgrHRS/7SxjMfiWkNmT67TtZoT1y6+Q==
X-Received: by 2002:a1c:e709:: with SMTP id e9mr2204110wmh.14.1555578420037;
        Thu, 18 Apr 2019 02:07:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyuedQ4xej5hVB7f/RytKu0Tq+8F0YO9bQ0Y4xTl0rnx/lWkTfJfA/d6qgfjQcjELW3gnqv
X-Received: by 2002:a1c:e709:: with SMTP id e9mr2204066wmh.14.1555578419318;
        Thu, 18 Apr 2019 02:06:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578419; cv=none;
        d=google.com; s=arc-20160816;
        b=mq0ZQ0plVAkxf2i0sk8H1fW5FUitLl3U5VKmVszEBsaR5bljHX6RaDHHq/VabMDVbO
         V0LBeec4TCQj3uapQk3bRku2lQUlAGg93uQWlQ7HVPF8YpU8kqBg4nOo7f3fsiahVBK4
         839qb293RTaK0BN33zSBCiNAWKXcOu98xGjtga/iUO3YUiGJaNHtntxYqITTH57LJuCd
         1FbUi8epDdKZR3krvom4JkXIIhYUxMNOKQEJgmbhkK1wBc/Am6jcuz2bjtudQAE9WW3k
         AN/72/I5i3NTIZ1AuV5qIbIqqGEG8W0HQ6qS8YFazzbWRH3J6gsuV23NFC02BypUiFcW
         pVzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=NV6JAa7wwuylvkaEkDT0w0mvqeqkCtkC066wzQ8DD70=;
        b=mGMP6i4Z4JdQNKqHy1YJQnovVsnTnhMVs/b9gLT3UZem1Hgd4qsHO4f+HmTCr1590k
         EWQfHIBAZGGGU567aoklxFqhCU9x6WM55PRqEzeiCVPhb8HnO2F1Rn98tBGCDVJdTXzE
         bQGKF8O56vZeT/Zjb0NiMVRBGBsW9NKdAZ4L9mAOmruKD+6x4wbeqaYgDEBLg5iNZHsX
         hJgHJByJXQJoeaWN51/5cC0BSOrfJvgZA2OPKE5PXBhPgL44CdDwNWVtyI62di4b9beX
         LpWnpzdcZdoJymh6i7HYqbGOFRxQpUU9Fwqgr49LcJ6wUcItCKQGgr8srZqD1wIxK4v7
         nxpw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id t63si1180520wmg.27.2019.04.18.02.06.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:59 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH2zy-0001qB-1o; Thu, 18 Apr 2019 11:06:26 +0200
Message-Id: <20190418084254.270025615@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:32 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>,
 Johannes Thumshirn <jthumshirn@suse.de>, David Sterba <dsterba@suse.com>,
 Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>,
 linux-btrfs@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org,
 David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dmitry Vyukov <dvyukov@google.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Akinobu Mita <akinobu.mita@gmail.com>, iommu@lists.linux-foundation.org,
 Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>,
 Marek Szyprowski <m.szyprowski@samsung.com>, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>,
 intel-gfx@lists.freedesktop.org,
 Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
 Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
 dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
 Jani Nikula <jani.nikula@linux.intel.com>, Daniel Vetter <daniel@ffwll.ch>,
 Rodrigo Vivi <rodrigo.vivi@intel.com>, linux-arch@vger.kernel.org
Subject: [patch V2 13/29] btrfs: ref-verify: Simplify stack trace retrieval
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
Reviewed-by: Johannes Thumshirn <jthumshirn@suse.de>
Acked-by: David Sterba <dsterba@suse.com>
Cc: Chris Mason <clm@fb.com>
Cc: Josef Bacik <josef@toxicpanda.com>
Cc: linux-btrfs@vger.kernel.org
---
 fs/btrfs/ref-verify.c |   15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

--- a/fs/btrfs/ref-verify.c
+++ b/fs/btrfs/ref-verify.c
@@ -205,28 +205,17 @@ static struct root_entry *lookup_root_en
 #ifdef CONFIG_STACKTRACE
 static void __save_stack_trace(struct ref_action *ra)
 {
-	struct stack_trace stack_trace;
-
-	stack_trace.max_entries = MAX_TRACE;
-	stack_trace.nr_entries = 0;
-	stack_trace.entries = ra->trace;
-	stack_trace.skip = 2;
-	save_stack_trace(&stack_trace);
-	ra->trace_len = stack_trace.nr_entries;
+	ra->trace_len = stack_trace_save(ra->trace, MAX_TRACE, 2);
 }
 
 static void __print_stack_trace(struct btrfs_fs_info *fs_info,
 				struct ref_action *ra)
 {
-	struct stack_trace trace;
-
 	if (ra->trace_len == 0) {
 		btrfs_err(fs_info, "  ref-verify: no stacktrace");
 		return;
 	}
-	trace.nr_entries = ra->trace_len;
-	trace.entries = ra->trace;
-	print_stack_trace(&trace, 2);
+	stack_trace_print(ra->trace, ra->trace_len, 2);
 }
 #else
 static void inline __save_stack_trace(struct ref_action *ra)


