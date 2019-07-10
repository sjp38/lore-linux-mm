Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,URIBL_SBL,URIBL_SBL_A,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45F7EC73C7C
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 09:27:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE18020838
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 09:27:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JSdyyNT2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE18020838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85A3D8E006C; Wed, 10 Jul 2019 05:27:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80CD98E0032; Wed, 10 Jul 2019 05:27:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 721658E006C; Wed, 10 Jul 2019 05:27:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3D2028E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 05:27:23 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id j12so1004586pll.14
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 02:27:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=rI79wxBh68/JZUpMRbvQqMhgwhim3RNzBK0rLg9/Jvo=;
        b=RL1/i+1bwlpSB7Ips2Eyny99iTALLwCqfp8+YHuBN45Ho8FhPOb9QFiXDIAEIGHh2v
         HZ05I660lIgOe+nUAzAtjcLYwaEo4D5mHJ6wB8fJmY671H6J/JxItdDe3SjrEWIoGhnA
         KN9mDtm7EkQFf6ETaL3grQulDc4QhUvil9VVPJuIap6D8VnkkDnIyGN179VvvkgUxfU+
         ckWjDzF0PpdCuxixiCm2la5zzSMBHtvEqzXJMStYLMHLHlBA4fAgHBJ5Zf84VAtUmqpY
         yf+Fp8m44I4t7jlsf7p9rSMXlHG5/lH7EfPlLpTYRVBADiVD9vCwXs/Md8ttibJ/6+dz
         jaeg==
X-Gm-Message-State: APjAAAX/LgUgyc+Gj1QWPP21tcJZRhMAQIiQAN5rUHtiuhUuJwD2LzUX
	sMbqf1EQ57fv8g4/YMbBVjcVP/sVyJr5m1DaILXz3O5Ub76KZbUFS4KhV/bpoAsHCyoRHy51Yss
	8xnJxPvvcP6hlIKGQMytWurFzfXzoiNAWv7BsrcEii7J7E5d9GJP3c/jU5qV0DFLRZQ==
X-Received: by 2002:a17:90a:21cc:: with SMTP id q70mr5994806pjc.56.1562750842885;
        Wed, 10 Jul 2019 02:27:22 -0700 (PDT)
X-Received: by 2002:a17:90a:21cc:: with SMTP id q70mr5994744pjc.56.1562750842104;
        Wed, 10 Jul 2019 02:27:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562750842; cv=none;
        d=google.com; s=arc-20160816;
        b=VZSaW1QCqE/5QJzHJv7aMLXXEGlMi21yL06/kiJTSh2MBlLVdBcs7iSerCweLa9lhJ
         +72nMTKjjYQACN4lRmM+2p+T6SZ+kOhTcrsRl1V04RhMiuLd04EgdUDNrk23ukt51r3d
         JMMBM4+/JuhQ2Ont89RaLS2B8wHfsL5v2c0Mv4PgBcc+tTa0dsbGBRnmVjB41NW1Gs0/
         xS7Qo26BjRVTjQjPQF73WIbIIyqhyo6QZYi3rHbSeEEjrXs0h8D9fGzjFbkizymr4Usf
         YxBe+9h+oKHPoI8PDcLjtckAktjXR9sBpf+KzSvPuP3gXGVLU5vGfQJCgC+lkqpD566c
         67aA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=rI79wxBh68/JZUpMRbvQqMhgwhim3RNzBK0rLg9/Jvo=;
        b=Ekk54zi5By1iuP5yYLKUK+LeAKKKHilXWzHu54ZyeJaqgeadPaECxLC09xniX36v0E
         pCkmIg69j4IqZDHV+R72Wyf4BGt6Mrs5YRTiL8ifpw9YGHOiD1SFck9aVnj9aO06NLEZ
         DrX/IuE5CWe08mA8LFiSq1+RJumrj0yt1n2YjSHk1kjxMTEfVsZSbGMm+1sUUNOBZHmd
         RU9CEyeaCkFYwoj4OE5BEbGatFDuPMkh9XVLbEFNwz/k/cpDfdqO9DJE3eF6h5FqviGA
         cK1EwHC7KGu5pWFv7nC9h7MdYXRBg2SW3Ji2KQGblWrJ+5U2DZcMyhlTSswVWV2T+kS0
         On5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JSdyyNT2;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m23sor754127pgv.70.2019.07.10.02.27.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 02:27:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JSdyyNT2;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=rI79wxBh68/JZUpMRbvQqMhgwhim3RNzBK0rLg9/Jvo=;
        b=JSdyyNT2dGlQE/JaLd28RbtGNjDD9xtO1cv1/NuIzbiSshAvUNiG9rb8AJhGdReVD6
         O4+lfaeCbbOUgvnMCC1FSJPMswlo+AAixpMboPbbRE0Vbztyx4pSdZS8UvCQliXPuxtt
         /Aajgv2uydoGfxe8QwepfEB0Hd9sNPi6LSRXT7v3q0B3xzErW8YGDpRfl8YvR9d1EsKh
         73e53vv5+d2qsQqgOsbzOgYUMoKmEaK6SSeIvuxAdjrw+o8pT9t9lrTbYag4s9MBXaA0
         zzmIvwhCsTf6CL3kbmmXeq0sj23AHlIQrHmvFGKsHvw8crLhIupH3QCK6cjewDRb0o44
         1r3A==
X-Google-Smtp-Source: APXvYqwNZPWV4skPDZdy7xfqsSjeDcuZYurVpLZ3V+GU6VZ9RQG153AZf5cDnJKCluL2CWNFww/jDw==
X-Received: by 2002:a63:fa0d:: with SMTP id y13mr35888947pgh.258.1562750841707;
        Wed, 10 Jul 2019 02:27:21 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id m16sm1565746pfd.127.2019.07.10.02.27.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jul 2019 02:27:20 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: [PATCH] mm/memcontrol: make the local VM stats consistent with total stats
Date: Wed, 10 Jul 2019 05:27:03 -0400
Message-Id: <1562750823-2762-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

After commit 815744d75152 ("mm: memcontrol: don't batch updates of local VM stats and events"),
the local VM stats is not consistent with total VM stats.

Bellow is one example on my server (with 8 CPUs),
	inactive_file 3567570944
	total_inactive_file 3568029696

We can find that the deviation is very great, that is because the 'val' in
__mod_memcg_state() is in pages while the effective value
in memcg_stat_show() is in bytes.
So the maximum of this deviation between local VM stats and total VM
stats can be (32 * number_of_cpu * PAGE_SIZE), that may be an unacceptable
great value.

We should make the local VM stats consistent with the total stats.
Although the deviation between local VM events and total events are not
great, I think we'd better make them consistent with each other as well.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Yafang Shao <shaoyafang@didiglobal.com>
---
 mm/memcontrol.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ba9138a..a9448c3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -691,12 +691,12 @@ void __mod_memcg_state(struct mem_cgroup *memcg, int idx, int val)
 	if (mem_cgroup_disabled())
 		return;
 
-	__this_cpu_add(memcg->vmstats_local->stat[idx], val);
 
 	x = val + __this_cpu_read(memcg->vmstats_percpu->stat[idx]);
 	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
 		struct mem_cgroup *mi;
 
+		__this_cpu_add(memcg->vmstats_local->stat[idx], x);
 		for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
 			atomic_long_add(x, &mi->vmstats[idx]);
 		x = 0;
@@ -773,12 +773,12 @@ void __count_memcg_events(struct mem_cgroup *memcg, enum vm_event_item idx,
 	if (mem_cgroup_disabled())
 		return;
 
-	__this_cpu_add(memcg->vmstats_local->events[idx], count);
 
 	x = count + __this_cpu_read(memcg->vmstats_percpu->events[idx]);
 	if (unlikely(x > MEMCG_CHARGE_BATCH)) {
 		struct mem_cgroup *mi;
 
+		__this_cpu_add(memcg->vmstats_local->events[idx], x);
 		for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
 			atomic_long_add(x, &mi->vmevents[idx]);
 		x = 0;
-- 
1.8.3.1

