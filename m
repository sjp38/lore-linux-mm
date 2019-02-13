Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34ED6C282C4
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 02:06:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1228222C1
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 02:06:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="AX9yHuMZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1228222C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFB318E0002; Tue, 12 Feb 2019 21:06:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAAF48E0001; Tue, 12 Feb 2019 21:06:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C98B68E0002; Tue, 12 Feb 2019 21:06:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id A2A0A8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 21:06:03 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id q15so745906qki.14
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 18:06:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=Hzqp/2bM8Ln/7TkhTNsRULjqW8T2TSZbSZrGbanUT7U=;
        b=bk7P/saee8my9VBSVgF3JUTjD79AR1FG2JZ8FD+3sXT+xvkakj+o0f5b4Sa/jtWa6c
         1a55IklWoZ+ihbG4RWiFOodxJvSkAvAgDEqirhD+sdZw7UapRYZcPSsKtrM0hhIah9x2
         XwVSObDDfvFsCTZsAWWvg9EQpFChHXMi+1uleaZ0z6re3FDKPTPIGtNtsszHGa2Bf/Zs
         WENX5vQId2O6Gq15COCTO3Xl0Ts3z4w2zUKcXCIz0zHp3MnOc+Xu7McrS6OHPUWN+5Ut
         VEUkJxpYjQs4MMxGtX5hvaJJtxuWHR8sS+bwqOAubKeti0akhxrHJTCgYhbTsmd4pnPx
         +sHQ==
X-Gm-Message-State: AHQUAuZQGalzp/BVXCvQtfFWxpgElSosnYe4GdwYmDOfEACAHdGpbmv/
	4I04UzRW556IQqxgBT6raL/aIeDguiThE6CWBNHeRpg+kUSG1xnwry4ONGFAhd2ONDpQh0Zp72X
	WNVMdC3P9t0BdQtSCWlLzs6UyB42t+XwAl/yPoeLxR3kB0NP2/q42F42iKzFVOkGoco1/ndsldY
	XINBn2ITEOmCUUdwWZbczxIAhh4Z9S/dYo/O34Lb9amw2NUQQn1tCnq7P3RPxoiD0XXAcfWrH/r
	m7w+hHN4QFPpgtlAdllgcj3XTaM0efOQa9PGKR4nYJ8ToreYHeE0Gq/MMiCKExLnQXyQ9qpDB1N
	L0HgD2zlAZv7QBG7sAQaMDqyyAbdEKWCUVdKrJrv+J7kvNe6jdnHzw83IapG9jjF/XVXk2zlZbt
	1
X-Received: by 2002:ac8:814:: with SMTP id u20mr5167157qth.313.1550023563356;
        Tue, 12 Feb 2019 18:06:03 -0800 (PST)
X-Received: by 2002:ac8:814:: with SMTP id u20mr5167130qth.313.1550023562643;
        Tue, 12 Feb 2019 18:06:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550023562; cv=none;
        d=google.com; s=arc-20160816;
        b=z/xRMvNyyZY+igZ6jNM+nmobt8VuIg8UVwoAFXEICBbtDucojSzN7E6Uom304yxRfK
         nc5PrlY0gT5Dp2/Yuns8iBEGcyJcYtZgLznUsgVM5+Jz78UVS7rTapgSlA2ZykhOK02i
         VQ7q4lSMNXuCB6125rYwxidBE0eAq1t47K9lxvHrVuVNIBl6BUFFzodk2CKcpnWgEXaZ
         QrusgbXMuXC/cGygz1Te3DdTGc/aXvZQKKSagD+6SIAH7JQZvXo9KyWct2jfWVZ8XwgU
         I6RsMYJ4mPfw3NvlOhLweDy1O/7zsqWDB+vEqJVWMQFcFlIcsOMKWS5oF3iKn6mS7iiH
         /GSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=Hzqp/2bM8Ln/7TkhTNsRULjqW8T2TSZbSZrGbanUT7U=;
        b=cb8i1daQjd/y3WEWXjsxsfuJJEoxH+9fsUkMEteRuTX1YcHRCR5nXwm9kTcoEHAmgC
         9pfdtVXtp31NcrAr8uCG+pioMDzLDbR2yYT3bq1f6a86pwmV1aZ7NPa96WeWqM6Tw2jv
         KOozluQivHtiQ2u3aijBloBpQXaZ24W/0ZzgvGoKhP6gPpuvyGQI9iBBw6OF8/iG1s1r
         72qLygVAu/I5fgbzyV1tfZDLIx6dWL86pBMMALCt5obRAjCFBsFMyOApK6FqMnFvVP0Q
         l3pSzQ/G2t2niXRg/EE0a2UmpTsFUUU7tfjdUpCgg0jKwyUhM9L+BQ40KfZJf9XElR6t
         /flg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=AX9yHuMZ;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t11sor14007667qti.36.2019.02.12.18.06.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 18:06:02 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=AX9yHuMZ;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=Hzqp/2bM8Ln/7TkhTNsRULjqW8T2TSZbSZrGbanUT7U=;
        b=AX9yHuMZrU88mfRrZB+kXyI/eDjSdmrvx9Gx8HRkcX2OGNeTUW29/XMx1oBGTSvO99
         +ACOQkHH7VT3sgskBBk06L1/JZLUaShZTSKC6hgRxZ9C/41R3DqKcNL+kAZMRQVZ7AaS
         aEpNql+YKebvFL5aAQUz0lfHtlNNdBZtAndaklHcNmvMEwTOBcoAe2F8zOGKpSwoz6oa
         GM2S7mPHQsqgULmMNyKGXQSn4G8qHIg8+DWOdDBbCgv7pF0TjuEkekrb6iZ5ztBUjIXK
         U+uVIzPvaMCJ06whnYLOGZYIXA1ZcQrcst/S88BPdmI7hoDjy1U5nk2tA9vKYZUUIHxv
         z4cA==
X-Google-Smtp-Source: AHgI3IZcRcbgHIbMtfTqBEwKGEYeameIk54dQrq7XP23nFPd4AlL9pskb3vbFrk/PplY/l+f9b9Dkw==
X-Received: by 2002:ac8:26b9:: with SMTP id 54mr5269401qto.301.1550023562237;
        Tue, 12 Feb 2019 18:06:02 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id k55sm19900153qtc.53.2019.02.12.18.06.01
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 18:06:01 -0800 (PST)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org,
	cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com
Cc: andreyknvl@google.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] slub: untag object before slab end
Date: Tue, 12 Feb 2019 21:05:50 -0500
Message-Id: <20190213020550.82453-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

get_freepointer() could return NULL if there is no more free objects in
the slab. However, it could return a tagged pointer (like
0x2200000000000000) with KASAN_SW_TAGS which would escape the NULL
object checking in check_valid_pointer() and trigger errors below, so
untag the object before checking for a NULL object there.

[   35.797667] BUG kmalloc-256 (Not tainted): Freepointer corrupt
[   35.803584] -----------------------------------------------------------------------------
[   35.803584]
[   35.813368] Disabling lock debugging due to kernel taint
[   35.818766] INFO: Allocated in build_sched_domains+0x28c/0x495c age=92 cpu=0 pid=1
[   35.826443] 	__kmalloc_node+0x4ac/0x508
[   35.830343] 	build_sched_domains+0x28c/0x495c
[   35.834764] 	sched_init_domains+0x184/0x1d8
[   35.839012] 	sched_init_smp+0x38/0xd4
[   35.842732] 	kernel_init_freeable+0x67c/0x1104
[   35.847243] 	kernel_init+0x18/0x2a4
[   35.850790] 	ret_from_fork+0x10/0x18
[   35.854423] INFO: Freed in destroy_sched_domain+0xa0/0xcc age=11 cpu=0 pid=1
[   35.861569] 	destroy_sched_domain+0xa0/0xcc
[   35.865814] 	cpu_attach_domain+0x304/0xb34
[   35.869971] 	build_sched_domains+0x4654/0x495c
[   35.874480] 	sched_init_domains+0x184/0x1d8
[   35.878724] 	sched_init_smp+0x38/0xd4
[   35.882443] 	kernel_init_freeable+0x67c/0x1104
[   35.886953] 	kernel_init+0x18/0x2a4
[   35.890495] 	ret_from_fork+0x10/0x18
[   35.894128] INFO: Slab 0x(____ptrval____) objects=85 used=0 fp=0x(____ptrval____) flags=0x7ffffffc000200
[   35.903733] INFO: Object 0x(____ptrval____) @offset=38528 fp=0x(____ptrval____)
[   35.903733]
[   35.912637] Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[   35.922155] Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[   35.931672] Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[   35.941190] Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[   35.950707] Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[   35.960224] Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[   35.969741] Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[   35.979258] Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[   35.988776] Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   35.998206] Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   36.007636] Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   36.017065] Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   36.026494] Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   36.035923] Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   36.045353] Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   36.054783] Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   36.064212] Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   36.073642] Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   36.083071] Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   36.092501] Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   36.101930] Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   36.111359] Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   36.120788] Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   36.130218] Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[   36.139647] Redzone (____ptrval____): bb bb bb bb bb bb bb bb                          ........
[   36.148462] Padding (____ptrval____): 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[   36.157979] Padding (____ptrval____): 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[   36.167496] Padding (____ptrval____): 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[   36.177021] CPU: 0 PID: 1 Comm: swapper/0 Tainted: G    B             5.0.0-rc6+ #41
[   36.184854] Call trace:
[   36.187328]  dump_backtrace+0x0/0x450
[   36.191032]  show_stack+0x20/0x2c
[   36.194385]  __dump_stack+0x20/0x28
[   36.197911]  dump_stack+0xa0/0xfc
[   36.201265]  print_trailer+0x1a8/0x1bc
[   36.205057]  object_err+0x40/0x50
[   36.208408]  check_object+0x214/0x2b8
[   36.212111]  __free_slab+0x9c/0x31c
[   36.215638]  discard_slab+0x78/0xa8
[   36.219165]  kfree+0x918/0x980
[   36.222259]  destroy_sched_domain+0xa0/0xcc
[   36.226489]  cpu_attach_domain+0x304/0xb34
[   36.230631]  build_sched_domains+0x4654/0x495c
[   36.235125]  sched_init_domains+0x184/0x1d8
[   36.239357]  sched_init_smp+0x38/0xd4
[   36.243060]  kernel_init_freeable+0x67c/0x1104
[   36.247555]  kernel_init+0x18/0x2a4
[   36.251083]  ret_from_fork+0x10/0x18

Signed-off-by: Qian Cai <cai@lca.pw>
---

Depends on slub-fix-slab_consistency_checks-kasan_sw_tags.patch.

 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 4a61959e1887..2fd1cf39914c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -503,11 +503,11 @@ static inline int check_valid_pointer(struct kmem_cache *s,
 {
 	void *base;
 
+	object = kasan_reset_tag(object);
 	if (!object)
 		return 1;
 
 	base = page_address(page);
-	object = kasan_reset_tag(object);
 	object = restore_red_left(s, object);
 	if (object < base || object >= base + page->objects * s->size ||
 		(object - base) % s->size) {
-- 
2.17.2 (Apple Git-113)

