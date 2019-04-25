Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4DB7C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99CF9206BA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99CF9206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F3D46B026F; Thu, 25 Apr 2019 05:59:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47B646B0271; Thu, 25 Apr 2019 05:59:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 394366B0270; Thu, 25 Apr 2019 05:59:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id E39FA6B026E
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:33 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id x9so20463660wrw.20
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=jB9SA5hdGExIFIDrZWtnR9KIYGIDvN3B6de51Ujrkgo=;
        b=baZfy2EtMBUdPrfnVvEdMdG7EG4k5ewGCC793lut3rX0j35Vwa/rkjwLupcyks726k
         JtrHQ+ggHDM8bi7ZztlBzarY9l7BQw1v51paVGdR+FPwrmK+U4+e2HK7Oh4Ek6TC3+df
         gaUfP9RgLwnZwDxi5USLaFYkrT7yaIOcvwNmYTI1KgGSewX1TJmku4Rpv1PzIr5n0lSS
         rrniIzIOWz/SG4z/ylU7DCCpmO4b22DBCqtyjqLkcZu74W3nqH9zN0oEWsmlgKFhQse4
         ybvTdeev6xKHEQP7XW+h53aoHghtF5CZ+85lEszOqwb5uOITOczQhfRb1rAG0BI1S/s3
         8Uzw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAUTkR9ngMgZA2v7Hx3u1VycAkWI6CYxD8QxNOFGZWPhP1/TYMdl
	PQdhRqUtY2SFGRRL0pVQFfAiMx1WO6iaBfVnEgam354JW5lglHFDaXqd4ZhYAyLpcBSoiXX4Oxe
	gBIVqzgNjgiz63F9kuwlWjzvqCRPArh25iG5UypueZwkR0VJ6sVaJcT5quGilIcgAnA==
X-Received: by 2002:a1c:9950:: with SMTP id b77mr2589899wme.133.1556186373464;
        Thu, 25 Apr 2019 02:59:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzj8Izz9ICHCbUCysEraF/HZK04aVhdtPYarRJECqCCFPbOotD+ls1IhebUCwXGXDJdGjb3
X-Received: by 2002:a1c:9950:: with SMTP id b77mr2589825wme.133.1556186372204;
        Thu, 25 Apr 2019 02:59:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186372; cv=none;
        d=google.com; s=arc-20160816;
        b=FOcmv9jtuJ1tWeITsYl7LlXrRXEvfsujTLg+TeXGgFe1vdu69bs39nKSMiD+pC2Y+z
         fkjuFSUX0dfPTLsCIdgAn7tBL80oH3IC5uEFsNZzG0kTN1iXD8TrcAWAvEQWABfESK+L
         6kvKz2UzIoag58O5kjdyzw9Nky1hOgRK2rpPgmSsDzTXWYgn2Pb9KBuPZTa2S+acyCAU
         gWG6HD0bl5mBugbz6bMyZvyp/ZYe1IbQrd5x1UsYurngyR7aAHKyQGkOpIDHFJaJ25AY
         v8NGG+2uf86O35JWOHiTcNXq+zehm7aRFI2Oyn6QzYIH8EyL+aYi29dAaARM7TXzp8fo
         YZiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=jB9SA5hdGExIFIDrZWtnR9KIYGIDvN3B6de51Ujrkgo=;
        b=nYS0DxvgvqriCTQQNV3E4KP2QHi3kVchSxRzmJISHVhO1Vj+NksFWRPgCHLstX86uU
         qSSIkDbkvAoZaIZV3qF49lwNDxeUdMpv+PMWmfUc38VpqvRRSarOdtzfyabTfEcnH3Ku
         b67+sUU0Vk76pFWaeLtIuLs4cxZ4gc22gTCKIJvf5mr1YY/JRVZM90fg5j0+uSq2U90h
         fgwuoJ+nBDcX9Ul8JLIy0Vj2OLrjdP4jmV4pzoHsKmcGnz1TX+LMxjvINQIkoK+ubJwo
         yq7RNUUOzoBKHTlqbFYR1uIQH/szYa+DQKMFN3jBSHIezYykVuTnZwyXCTK7wtcf44il
         jl7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id o14si16519334wra.84.2019.04.25.02.59.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:32 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJbA6-0001uB-F4; Thu, 25 Apr 2019 11:59:26 +0200
Message-Id: <20190425094802.716274532@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:45:10 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
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
 Tom Zanussi <tom.zanussi@linux.intel.com>, Miroslav Benes <mbenes@suse.cz>,
 linux-arch@vger.kernel.org
Subject: [patch V3 17/29] lockdep: Remove unused trace argument from
 print_circular_bug()
References: <20190425094453.875139013@linutronix.de>
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


