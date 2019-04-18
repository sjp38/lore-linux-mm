Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06C86C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C432A2183E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C432A2183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F4376B0010; Thu, 18 Apr 2019 05:06:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 584BC6B0269; Thu, 18 Apr 2019 05:06:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3FBDA6B026A; Thu, 18 Apr 2019 05:06:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id DEEB26B0010
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:15 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id k17so1525759wrq.7
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=ndPMY5lfafu/EZtXmPJOgPVCY5qMZpY8tacLKTDS9zk=;
        b=Pk3YnYJvUHMnYQ7fi7i9K4sL3J+PYy5Ke6XmPb51ZPCv4QE+7Ik5lMzO+YLIaVBBiN
         BwqhUg1lrG1s3eJUO3Fsy1yP9GjQKlLlblvcdlB2UdhA3AV1yW/8cSs+qfoc2JaWZ1iW
         YAYrCE3TDkPyV8YeuNtGBYLGwocSX6M+dGw8iwSD5WGt3e5cbaabXuGrUfHMTsCwrO52
         aU3xAN89uJaV5/RWK+MvCYHIHH3v73WV/NMaZ56tuMcRPlyu4GdTUUVBZgqQPRyuR497
         n+XMbtM5xNVYVIGhVbTkiouoDByuQoUOd144Llcq4fswA8uHFZroUXRRS/4U3mT+8Hct
         zXOw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAXQO/rFGqrWw3mNJxDAiNPXYj2AUHC1WvlxyWCg4K0Z3a2QgkD3
	sLNa2Av0z4ZxqVs/f1Tka57Sp2vpghmIkmKiJnZWb+YAsG9Q6koy2ddYMpasyTrT0z1f7cCdQr2
	zg6U2vTONrzKyAv3hxDTEVgULQwF4qbsTsFzL8SuxKjpPtFKbJvzKsf6r9gKzwcFtrg==
X-Received: by 2002:a1c:2246:: with SMTP id i67mr2209475wmi.148.1555578375439;
        Thu, 18 Apr 2019 02:06:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzw56sN8U5xexBs784LmZGqb793r+1BwbIlCgB+Wtr4fG242biYnAljKV5XCu8uueGeG59D
X-Received: by 2002:a1c:2246:: with SMTP id i67mr2209395wmi.148.1555578374325;
        Thu, 18 Apr 2019 02:06:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578374; cv=none;
        d=google.com; s=arc-20160816;
        b=tvkPKxA8djFWnkr6fqskuYl5TELrPtJcoO1EKkRKY/Sw4XOS3v+ZdLQoGOwDEPKqkc
         w6rU8zLdmO1vgIDNpBzU6GU8aqZr/j0E4RuY9Qq/QC0jTdYBU+g8lC5cG2NyNa85doVX
         IXVhFsEjajc8Y2VcT867c7DO6XaFfFxs/1lr8jnv9hEKnntdBgTsRGFC33bD+R3evFoS
         1se3J5gEaobrJOWIZ24qVKrNR9TIDuc50pIAvPdPdCM2RhiUU/ydDJAN/c3h4ft4W5WY
         TmmYup1CJ9wN336zuNhWAaLKiOqQw8R362aYO+15r4++Em+qA2GoilRj70xkYCQnsg33
         QnLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=ndPMY5lfafu/EZtXmPJOgPVCY5qMZpY8tacLKTDS9zk=;
        b=PDP4TXicDSBtReAeIXfUHjlTAsTFXd9aLWRwtrixtcM2tDU+ZmLuOZ+Pxib7aGpK3h
         yHHIITF+/WKEYnJB/UNwR3qVkNE1DEl9lEvJCEvbtK+TEm8yTYAyNYBdYy56nsElVvZI
         TBijnEIEq/wAo50N0ODoCdT+k2+RN6lJkNKZZAuLDP2GtBfJBu/TZUPiljy+i5HoPCoL
         qKfXCalE1vydF19jbJQzokk1LQmAM5qNWLKb+rFOs1tCssIwe6XDlfky1ZjCMGQYGmkM
         Q7/eaw+QuqyNtSboDtQ6BCscL2kWLWerkw0GTZhRx73qH3W2gSIaSg2Mbzs2r6OVpjk6
         UPSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id c8si1189775wro.416.2019.04.18.02.06.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH2zj-0001n0-DA; Thu, 18 Apr 2019 11:06:11 +0200
Message-Id: <20190418084253.628227766@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:25 +0200
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
Subject: [patch V2 06/29] latency_top: Simplify stack trace handling
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
---
 kernel/latencytop.c |   17 ++---------------
 1 file changed, 2 insertions(+), 15 deletions(-)

--- a/kernel/latencytop.c
+++ b/kernel/latencytop.c
@@ -141,20 +141,6 @@ account_global_scheduler_latency(struct
 	memcpy(&latency_record[i], lat, sizeof(struct latency_record));
 }
 
-/*
- * Iterator to store a backtrace into a latency record entry
- */
-static inline void store_stacktrace(struct task_struct *tsk,
-					struct latency_record *lat)
-{
-	struct stack_trace trace;
-
-	memset(&trace, 0, sizeof(trace));
-	trace.max_entries = LT_BACKTRACEDEPTH;
-	trace.entries = &lat->backtrace[0];
-	save_stack_trace_tsk(tsk, &trace);
-}
-
 /**
  * __account_scheduler_latency - record an occurred latency
  * @tsk - the task struct of the task hitting the latency
@@ -191,7 +177,8 @@ void __sched
 	lat.count = 1;
 	lat.time = usecs;
 	lat.max = usecs;
-	store_stacktrace(tsk, &lat);
+
+	stack_trace_save_tsk(tsk, lat.backtrace, LT_BACKTRACEDEPTH, 0);
 
 	raw_spin_lock_irqsave(&latency_lock, flags);
 


