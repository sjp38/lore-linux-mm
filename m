Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C140CC606AF
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 12:48:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8222C20665
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 12:48:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8222C20665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11A1A8E0012; Mon,  8 Jul 2019 08:48:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C9DA8E0002; Mon,  8 Jul 2019 08:48:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F22718E0012; Mon,  8 Jul 2019 08:48:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id A7A4A8E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 08:48:11 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id e6so8131636wrv.20
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 05:48:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=I0ID9b0H+zcj5NnrvpKFC0Y/+i8u3r5flC2mQlpHLJU=;
        b=O3/LnytBWp3kWG3556svTJO7ADXs8Ru00fjiSgbKMKDgzhUypFqzyoDoEGcXbwmAp8
         oiFXTNubjuof+TuvJhdZNR6HM2wO52zDmMzrwaBGDjTlMmd+HVJkof9NChV3h+qOK0/u
         jrr+g5yJFT2kIzNLwSXVNFqLdA2mKAVcTHw1uUxSe/6M3/AMWz05j3bEEF7YTd6DCOtR
         oRVAGbWG1VhKLNbzQQKmQ6mkzHb7FxK+L7C17T11P/6an+w3H0KaL3l54hfAGUO+kT+x
         MEpGGOWr8BVFj0Edc+TBrLpkDIuMHrKrmpDkVPeqL2gPcVlLntY1xP/HkmjxsrzD4wqU
         Rv/g==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 212.227.17.24 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
X-Gm-Message-State: APjAAAVCJ6rn0pi/RMJU4dK4z6MjrNUqVwgiIS6z6CGGOezEk21cckr0
	I/Pr+CHJ6lA0Pc7SVF7yWmdRR6YJ/LGssxFnMdPZkFJ/dAmPMWlBQdBfDkrJ3v83fXO/pl/95+G
	JZZV/lv3CR+tek1ptE/U7Y7mhtKjmwAz32XKraaq2KNYxNMcNyMrCoipVoyaAjjs=
X-Received: by 2002:adf:979a:: with SMTP id s26mr18868528wrb.13.1562590091165;
        Mon, 08 Jul 2019 05:48:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5eERRMAJcMf8+ah9t89npN7YNq5eps1OcLrVP/bnFKEY6uZ92TDOn7nkz9LMbAQU1PBFV
X-Received: by 2002:adf:979a:: with SMTP id s26mr18868482wrb.13.1562590090322;
        Mon, 08 Jul 2019 05:48:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562590090; cv=none;
        d=google.com; s=arc-20160816;
        b=Y7OfifEpM2H3dgHYeICftjayv3ki9Cd8xYtsuQUlIyEPVNtNkr59HnrivEAZ71A8Im
         aIl0XyuykKzYEglIabCJrOWwhw5TCxjKbE//9fKIfGNLYgJY1VqAet2lxM7FmuDsduo5
         tgERPeiAoC8gprnnMZjBhnEJULoc7Oi0z+94IHLRbWCfTZ2rvJG1VEP4IDcvM4mMS025
         6jjVgNp6QNA4XKBS9lX1pFwCZLWQOtzwdilo/gDJx1BVPqasDp678xsBX8lGIHC6TG0j
         dkzHlZgY7RoYZ+L/UkPqBkVm3TVmhXz0heDwjGgaVaNXSLjBWev0acvsLkW5gKNanYYc
         QTEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=I0ID9b0H+zcj5NnrvpKFC0Y/+i8u3r5flC2mQlpHLJU=;
        b=Gt6oGnytrz1B9EVfl1R7aEuDDzvPRQOiE+orhgncz2QoKOUVaLJTU5F+T+S+u1uyGf
         3g5Nw7n//aJQUB4uAVCzlFsdPtPjqaqc0+eq7tfbn6kJ1nGL462FPsBJRMD1rPAKZfwm
         +6G1J94gU5OwcyW9/2/u6Krj/HGkmfkRYrH2cIU5/JZLcr2ZsWqzJY49ymHHn+oCEA0L
         eoflf33DwmGLfJYMP7PfLmknL9UzEXAAP2YL5w6rv3VEg0F43okb36PgSnhesXO/UfeN
         ZHek37EpKHUM9HGnBS7PLBgYTHaCq3rXwnECDbEG+p9Pjw688/9Db3sAnQECE5Soiyao
         vj1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 212.227.17.24 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.24])
        by mx.google.com with ESMTPS id b15si13117921wrs.151.2019.07.08.05.48.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 05:48:10 -0700 (PDT)
Received-SPF: neutral (google.com: 212.227.17.24 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) client-ip=212.227.17.24;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 212.227.17.24 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from threadripper.lan ([149.172.19.189]) by mrelayeu.kundenserver.de
 (mreue106 [212.227.15.145]) with ESMTPA (Nemesis) id
 1Mduym-1iKMCm2862-00az91; Mon, 08 Jul 2019 14:41:26 +0200
From: Arnd Bergmann <arnd@arndb.de>
To: 
Cc: Arnd Bergmann <arnd@arndb.de>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@suse.com>,
	Hugh Dickins <hughd@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	David Rientjes <rientjes@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Roman Gushchin <guro@fb.com>,
	Chris Down <chris@chrisdown.name>,
	Yafang Shao <laoar.shao@gmail.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH] vmscan: fix memcg_kmem build failure
Date: Mon,  8 Jul 2019 14:41:03 +0200
Message-Id: <20190708124120.3400683-1-arnd@arndb.de>
X-Mailer: git-send-email 2.20.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Provags-ID: V03:K1:8VkSE5EXRvXhg4WTtl1yfmQwLxnuqIVBWC3O64OvYEpHsptKShz
 liGdVTsfLuFY0hhVyQVWbff5R3bnb6E1HJhu20u8pAvj9sk57oG0RsiWEA+A1bIP/Uugd9q
 2kMCOc7ttYjFkbS/CznPsTeFSIM1mWM86j4G6IquKv0/qHs1LJEQyDFHh4E7ePwwl6mD2aj
 jfri59CV9WSdBmPT0jJfA==
X-UI-Out-Filterresults: notjunk:1;V03:K0:Qrw0YFYZm3U=:VGs8TL30AkKdaSSzDZoooG
 C9IWLT6Dd8074lAPa/y0ZY4N+3IX/mZJcb7thkIzO7H+rN2Y0DPg9lR7QFFgwWJcaFFB0svJL
 BQ/QrPNuZCNOpmhvr4UkRFsmehPnqJ+cOM8/dJnU9VngZCtqWTVcmAPVj5LGubGJQW76C5P/q
 xEGN1Irtzyi1c/GG8bR1HgTwb50CInnd5NDuMYAXaY9oQ3/5m1n4UI1+DaWamLhOkPP7jqeLo
 NZJiLBDD0IyWOzK7cp1WIPeqRleTaZQaKLFfBETUvld8rv15RSkczdPmzUeSodPn4QK4HJWo8
 6rXxy27Ru+tQ0L1o5Y/AYgEn2hCF/MpR7htIiKvbbuI0ggs3dNl3F0cce7I5B6mSXwa9+CA58
 awyMa2fbHoyUZXuRg1zTd4d2tw5jA6ASzXMX/fXmFktYLJRxg3IKZBaQgc/XRqIQJpvUHP3nT
 blfK2yGVk/801H0Zifbc4WnEHBNXFM61CLJoTunCHYJKMZBO55hsuzJ7qQ/xd4CoZb5I689Wt
 BoxopmdByL2/i/8QE11/owtMG+1HhMxW/MDaXxjDPX8UG/BEq4MwkV0v+6fEtobE2C//PuYUz
 gvmoytlh3TuBiAmBqBnpolWC+ludvk4OE1v+D9rc+3jSVUHYQBbUlVeZpcqLbjiDLf4AP4RW5
 vWuXjKmj5FCz9buHUFBq2+X1t3aOUFtsbrQYAEOfD6cHWaH7vWuTM4Ptm0Gf/hqebqpKr7xh6
 L7hTgiqG4dvwjR/Bl1BVyHiHTBFQ5pvQjg9gyQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When CONFIG_MEMCG_KMEM is disabled, we get a build failure
for calling a nonexisting memcg_expand_shrinker_maps():

mm/vmscan.c:220:7: error: implicit declaration of function 'memcg_expand_shrinker_maps' [-Werror,-Wimplicit-function-declaration]
                if (memcg_expand_shrinker_maps(id)) {
                    ^
mm/vmscan.c:220:7: error: this function declaration is not a prototype [-Werror,-Wstrict-prototypes]
mm/vmscan.c:608:56: error: no member named 'shrinker_map' in 'struct mem_cgroup_per_node'
        map = rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_map,
                                        ~~~~~~~~~~~~~~~~~~~~  ^
include/linux/rcupdate.h:498:31: note: expanded from macro 'rcu_dereference_protected'
        __rcu_dereference_protected((p), (c), __rcu)
                                     ^
include/linux/rcupdate.h:321:12: note: expanded from macro '__rcu_dereference_protected'
        ((typeof(*p) __force __kernel *)(p)); \
                  ^
mm/vmscan.c:608:6: error: assigning to 'struct memcg_shrinker_map *' from incompatible type 'void'
        map = rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_map,

and another issue trying to access invalid struct fields:

mm/vmscan.c:608:56: error: no member named 'shrinker_map' in 'struct mem_cgroup_per_node'
        map = rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_map,
                                        ~~~~~~~~~~~~~~~~~~~~  ^
include/linux/rcupdate.h:498:31: note: expanded from macro 'rcu_dereference_protected'
        __rcu_dereference_protected((p), (c), __rcu)
                                     ^
include/linux/rcupdate.h:321:12: note: expanded from macro '__rcu_dereference_protected'
        ((typeof(*p) __force __kernel *)(p)); \
                  ^
mm/vmscan.c:608:6: error: assigning to 'struct memcg_shrinker_map *' from incompatible type 'void'
        map = rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_map,

Add a dummy definition for memcg_expand_shrinker_maps() that always fails,
and hide the obviously nonworking shrink_slab_memcg() function.

Fixes: 8236f517d69e ("mm: shrinker: make shrinker not depend on memcg kmem")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
No idea what the intended behavior is supposed to be for this case.
Rather than failing, should we actually provide that function?
Or maybe a more elaborate change is needed?
---
 include/linux/memcontrol.h | 5 +++++
 mm/vmscan.c                | 2 +-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5901a90f58eb..6b15e2066fc7 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -1407,6 +1407,11 @@ static inline void memcg_put_cache_ids(void)
 {
 }
 
+static inline int memcg_expand_shrinker_maps(int new_id)
+{
+	return -ENOMEM;
+}
+
 static inline void memcg_set_shrinker_bit(struct mem_cgroup *memcg,
 					  int nid, int shrinker_id) { }
 #endif /* CONFIG_MEMCG_KMEM */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a0301edd8d03..323a9c50c0fe 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -591,7 +591,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	return freed;
 }
 
-#ifdef CONFIG_MEMCG
+#ifdef CONFIG_MEMCG_KMEM
 static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
 			struct mem_cgroup *memcg, int priority)
 {
-- 
2.20.0

