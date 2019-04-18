Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36C78C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0067D21850
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0067D21850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE1EA6B0277; Thu, 18 Apr 2019 05:06:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D71436B0279; Thu, 18 Apr 2019 05:06:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C33546B027A; Thu, 18 Apr 2019 05:06:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6FF306B0277
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:40 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id n11so1552041wmh.2
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=jB9SA5hdGExIFIDrZWtnR9KIYGIDvN3B6de51Ujrkgo=;
        b=Jgh7tC+Q2uiai4wGEofz/2sUDk27A2cfRENmvFEO39a0F0VvBHX9lT66kMV8+PptoW
         DHnpe5UPh+BqO3TRNyWs6p8/l1drxgGH+czsjFuGwwwTnyJAtC2+5jrTsDTdl3lx09RN
         SqpdT27fWY/cGIW5Nr2MrJxuSYhxKde0X+mlWB9lF+hmgR5dK+/ADkTB7kJJAECaxUQF
         wtgsN1v4LVP2wP25I7KveMWfSDgPAPECpe7Aco208eAN2FVsSCKoOrKWOmbctd5bCzHL
         2ntDTANgVFXGFn9EqK2TAOBe4NgiNzoL/GZJmmXLEzSC6yHvloo7dSBmPK7buBT86U93
         4Gbw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAV5NF0kcYECFXzZ24FWa6kZ8W2nn602RR8iPpCwoOH4IiPk8HvI
	WWxhhlbpb4u9Y4pAQjJQJSmI6pyUX5QtB0k5MvubtUoVCNl6LlLjJHuXKdx21Vjwy0N2ZGVLwOQ
	SyVneYgTGEPthv0mFEuC/RQXTWZF+sik7vZOBdJaqd9mI5221AgIKaMkHk8o2DZ9Npg==
X-Received: by 2002:a1c:dfc5:: with SMTP id w188mr2141770wmg.79.1555578399987;
        Thu, 18 Apr 2019 02:06:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyGtMszvfXNQETW6cehLJ1GwAO4Tw8UBFE8vN9u51eFcMeCtKIgNI9UYS4qbGxffwR5nItk
X-Received: by 2002:a1c:dfc5:: with SMTP id w188mr2141710wmg.79.1555578399052;
        Thu, 18 Apr 2019 02:06:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578399; cv=none;
        d=google.com; s=arc-20160816;
        b=i4eZiK50NnqYCD8gSaEM//Fp3VsPvv0nfWzzrl+8eeEyduGwqYMwwkD9d3tk1S6vAc
         8GsIb6Ou3qspzoP5PrOQVZqQJVkRHS/fojaMExqszTrYDywcfshKpahuL/wwMy4HiJHI
         brueGu8veNnGqAJOtYpBwGyOyIwQeKZfXRSl8Ny0yvcGt4akkTpYPdQLWgWlNJZXv5sh
         6ewePKR/8rm0Tnc0wiw7Tmc79USfzqcxkZ/0Qga5KFBPuKZSAeADk8g0DgFqg+r4I0uq
         8foUt7jjHlhB5T995gVm3j/6cFVRe6MQ6/hqM6aVAKDzxVK0YKr0BLA5r0c4SZlx8E7G
         GBVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=jB9SA5hdGExIFIDrZWtnR9KIYGIDvN3B6de51Ujrkgo=;
        b=c6Ca0TBRn9RKMS+xKb4jBITUQyMbAJfYpzxdEAm5IxX9LYdHTQIVStnT/f4/Tm1xHU
         q2I372EpSOxVcn9daNd0uyQGwm+bEFJUjFzr1HoEMraUpt9d+8POY5gA2i44GG9T/0/6
         BIN1bS6Y2glAy1W5lgCnp/zGPDzNhuach0O38p00aJllwUwy5+JVM3z4F22PHcYnmCka
         FKrsYK4PbVJr7VsWLQH5T/ku+hqLf+HJLgJ+dPmXMGrmoLRVpv4JK5XqXcegGn6pPnzz
         G22sF96vjpe8ZkYK2HIgKW9kmfpKI9GqHONC8ejk8BA9d7tzNPvIDBmKL94g4A5Z+BwE
         k1/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id j145si1091466wmj.95.2019.04.18.02.06.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH307-0001sE-IN; Thu, 18 Apr 2019 11:06:35 +0200
Message-Id: <20190418084254.639634107@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:36 +0200
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
Subject: [patch V2 17/29] lockdep: Remove unused trace argument from
 print_circular_bug()
References: <20190418084119.056416939@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 kernel/locking/lockdep.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -1522,10 +1522,9 @@ static inline int class_equal(struct loc
 }
 
 static noinline int print_circular_bug(struct lock_list *this,
-				struct lock_list *target,
-				struct held_lock *check_src,
-				struct held_lock *check_tgt,
-				struct stack_trace *trace)
+				       struct lock_list *target,
+				       struct held_lock *check_src,
+				       struct held_lock *check_tgt)
 {
 	struct task_struct *curr = current;
 	struct lock_list *parent;
@@ -2206,7 +2205,7 @@ check_prev_add(struct task_struct *curr,
 			 */
 			save(trace);
 		}
-		return print_circular_bug(&this, target_entry, next, prev, trace);
+		return print_circular_bug(&this, target_entry, next, prev);
 	}
 	else if (unlikely(ret < 0))
 		return print_bfs_bug(ret);


