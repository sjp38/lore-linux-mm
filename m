Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 723ADC48BE3
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 19:28:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F4032085A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 19:28:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="fIKUsLLL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F4032085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFE0C8E0003; Thu, 20 Jun 2019 15:28:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C880D8E0001; Thu, 20 Jun 2019 15:28:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B29528E0003; Thu, 20 Jun 2019 15:28:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8DB5B8E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 15:28:25 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id g56so5053862qte.4
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 12:28:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=ujGIfxzGY9TqzTdiMJZwFKl+HRckfQJ/fxLK/7Xde4k=;
        b=kZcdqqzjFt/WiD58pSDosJzukZsitzMlIF6YHCi3ZOgdVIjW4aXsOG927tBOlM8Aa0
         nCw8Ppy/x+ny2Myc6FsqDcqGSwDwbgka96BS7sYwwxHi2+KiQWENR+Am/3IJP4QG/nC2
         5N2DYAW3bQ2AvaVNYdArBhWZJJnNgBiaH7M+Z4/Abax1B7jtV+Nq/WjPb03nN32ULkmF
         aEGrwsuVuqA+Lje1u123JUTH59iwvMqzBNciaojidSYQHm3F6jgQ1jkJrRwq/jnCJZEg
         INRvZcVw8mQTg+qDEkq3akWYlo2ZYVzh7/mAncqmwm41+s6xIJUpaJrh/cznibdROitN
         ft1Q==
X-Gm-Message-State: APjAAAX7qs5E7ohkQ4mvV4ARIL1SlSiKc140hrRrJK+BqR393N/XJ+ci
	tmspYiHmmjqqbnafaW2UzhQtRHbmFybZSpiOdLpiZUzVp6F5viWI01nClwX8kLWmUlaKSgH9ais
	SDNITbQwtFD1+hCACdfz6/Y94wPwwWdYF48U4sRF7K9myjo3BrTghazghv0/eA/5MdQ==
X-Received: by 2002:aed:37a1:: with SMTP id j30mr16518168qtb.367.1561058905104;
        Thu, 20 Jun 2019 12:28:25 -0700 (PDT)
X-Received: by 2002:aed:37a1:: with SMTP id j30mr16518076qtb.367.1561058903469;
        Thu, 20 Jun 2019 12:28:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561058903; cv=none;
        d=google.com; s=arc-20160816;
        b=iWrUH6T0Dh2ZMecVap6MrDgrx/DfSjkYou9QYnDiiXbN9C3gWOPyWNv1C7L3std5BX
         RyRcDe5PS4iCSyuo/A1zzypZKBsOLA7fBVnmd2nWoGhX7HN+lHsLst6ayGZwBawvwBAn
         pRbYP/RHJOe06SqHjZvYEhLW+PlzKrC4RAoaLMoNUJxH7dYKTfVBO2syHXXghK/DlDfF
         J1YHvSVpf0FyvvzpHz0HJVcPx6cKENZaUROwQG/DV9Hq4/hDOhe9h4Kh3jmd0YUf8jEK
         5vz8jZpIKJ+w5OW/WU0f1JscmWoBm48J4XOTtBWyIpfijVC7LPHaSMwpngLhb9DM1Ymo
         B58Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=ujGIfxzGY9TqzTdiMJZwFKl+HRckfQJ/fxLK/7Xde4k=;
        b=lDB51aifeFtKQpaNLSD+sUsP0H4SrX4CuJzA2HMoG1yw/twe9qQLZTjs8beS30lgs1
         sp0jrEVUKJpwJ1ovkOZXq9tq2QSKm3Ugdz4PWD1WRlgzF35GGlkP/4S0jQd+JhexKFLe
         0Os3qHe/JOswHlhQH2RUjBTR/E94EVQuTmP8HX0d9N2y9kYczAo5uba9COjb/drs6ghi
         WfbPdMqUx4/vOpCsLPBAaeIly/o5ootCKIjRlrupAn1pwFjd4/bVrqpMSJGDogg8XsSt
         t5mb0iphPowxSs7Z+L+YamW/OYjHWirRid9eG3n8mkW4Vgx9GaUE3gg7G2YI7if/5GKF
         H51g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=fIKUsLLL;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v31sor984627qtj.59.2019.06.20.12.28.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 12:28:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=fIKUsLLL;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=ujGIfxzGY9TqzTdiMJZwFKl+HRckfQJ/fxLK/7Xde4k=;
        b=fIKUsLLL1MF2v80JU2je+8J7L2Nt4JjusUm14K96ynmC9h8yQcDP+CWa+pNInBcPDY
         mpSjs0inZeZZPvHMH2gacj+1NcWVml5C5CQn+RYQOnsiyzutGoQvLsdg+h/o1Mxle/gC
         +zxz9RT1EMbg9fs03F3LH67K/qDWNmM2AVV9kyZ2rnm209V1aohx1Mp0J7jfnB6XYi/N
         /yfeND/KniGKCv3UdbYsq8UpH6xX8JatBcKCWsBd5WA+bSJZrhWPpGvc68pkOTki3P9W
         vMet0fULUI2fbLlMHiEbMxv2zCB9PeRZGW6Ay7mvsGIbewgkcsKkc8NsCmB1bdz8HZMC
         d7jA==
X-Google-Smtp-Source: APXvYqyGY5XC1WwDU2nKXLWGekQDUBaB26hL6bvlH72MC23nrdvked0HjHIA0MltVRW9gfSUq0Mn5g==
X-Received: by 2002:ac8:17ac:: with SMTP id o41mr41040317qtj.184.1561058902552;
        Thu, 20 Jun 2019 12:28:22 -0700 (PDT)
Received: from qcai.nay.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id n184sm214597qkc.114.2019.06.20.12.28.21
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 12:28:21 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: glider@google.com,
	keescook@chromium.org,
	cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH -next] slub: play init_on_free=1 well with SLAB_RED_ZONE
Date: Thu, 20 Jun 2019 15:28:01 -0400
Message-Id: <1561058881-9814-1-git-send-email-cai@lca.pw>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The linux-next commit "mm: security: introduce init_on_alloc=1 and
init_on_free=1 boot options" [1] does not play well with SLAB_RED_ZONE
as it will overwrite the right-side redzone with all zeros and triggers
endless errors below. Fix it by only wiping out the slab object size and
leave the redzone along. This has a side-effect that it does not wipe
out the slab object metadata like the free pointer and the tracking data
for SLAB_STORE_USER which does seem important anyway, so just to keep
the code simple.

[1] https://patchwork.kernel.org/patch/10999465/

BUG kmalloc-64 (Tainted: G    B            ): Redzone overwritten

INFO: 0x(____ptrval____)-0x(____ptrval____). First byte 0x0 instead of
0xcc
INFO: Slab 0x(____ptrval____) objects=163 used=4 fp=0x(____ptrval____)
flags=0x3fffc000000201
INFO: Object 0x(____ptrval____) @offset=58008 fp=0x(____ptrval____)

Redzone (____ptrval____): cc cc cc cc cc cc cc cc
........
Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
................
Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
................
Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
................
Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
................
Redzone (____ptrval____): 00 00 00 00 00 00 00 00
........
Padding (____ptrval____): 00 00 00 00 00 00 00 00
........
CPU: 0 PID: 1 Comm: swapper/0 Tainted: G    B
5.2.0-rc5-next-20190620+ #2
Call Trace:
[c00000002b72f4b0] [c00000000089ce5c] dump_stack+0xb0/0xf4 (unreliable)
[c00000002b72f4f0] [c0000000003e13d8] print_trailer+0x23c/0x264
[c00000002b72f580] [c0000000003d0468] check_bytes_and_report+0x138/0x160
[c00000002b72f620] [c0000000003d33dc] check_object+0x2ac/0x3e0
[c00000002b72f690] [c0000000003da15c] free_debug_processing+0x1ec/0x680
[c00000002b72f780] [c0000000003da944] __slab_free+0x354/0x6d0
[c00000002b72f840] [c00000000015600c]
__kthread_create_on_node+0x15c/0x260
[c00000002b72f910] [c000000000156144] kthread_create_on_node+0x34/0x50
[c00000002b72f930] [c000000000146fd0] create_worker+0xf0/0x230
[c00000002b72f9e0] [c00000000014fc6c] workqueue_prepare_cpu+0xdc/0x280
[c00000002b72fa60] [c00000000011b27c] cpuhp_invoke_callback+0x1bc/0x1220
[c00000002b72fb00] [c00000000011e7d8] _cpu_up+0x168/0x340
[c00000002b72fb80] [c00000000011eafc] do_cpu_up+0x14c/0x210
[c00000002b72fc10] [c000000000aedc90] smp_init+0x17c/0x1f0
[c00000002b72fcb0] [c000000000ac4a4c] kernel_init_freeable+0x358/0x7cc
[c00000002b72fdb0] [c0000000000106ec] kernel_init+0x2c/0x150
[c00000002b72fe20] [c00000000000b4cc] ret_from_kernel_thread+0x5c/0x70
FIX kmalloc-64: Restoring 0x(____ptrval____)-0x(____ptrval____)=0xcc

FIX kmalloc-64: Object at 0x(____ptrval____) not freed

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index a384228ff6d3..787971d4fa36 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1437,7 +1437,7 @@ static inline bool slab_free_freelist_hook(struct kmem_cache *s,
 		do {
 			object = next;
 			next = get_freepointer(s, object);
-			memset(object, 0, s->size);
+			memset(object, 0, s->object_size);
 			set_freepointer(s, object, next);
 		} while (object != old_tail);
 
-- 
1.8.3.1

