Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60384C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 15:43:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D68D2087C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 15:43:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="UnRUcSI4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D68D2087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5191F6B0003; Tue, 26 Mar 2019 11:43:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C8566B0006; Tue, 26 Mar 2019 11:43:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B8A46B0007; Tue, 26 Mar 2019 11:43:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1D44B6B0003
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 11:43:54 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id g17so13894684qte.17
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 08:43:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=xPwO+VfBDlBl+yGZj+3rGMuEeXiQlCjRxp+hpH3Hq0A=;
        b=Ecdn9ASZhykL0kpIfcTzzKi0B3/ZOOmLtvAbymTgmSSvkbuARLDG9xG4Kf20InekbC
         FWblxGjhTxeNnDceeMb86y+briK5y4c8urXwlJsbasy9jSHbJeJByw94c2FNbHodhN+c
         4eSmo59Xl9K8psGywGeCEvNenBlFx8i8A1kYJV66VwgXZ1dhbyWZF3HXWzbEId0hhsVM
         J5A5UP7jzhhMZDrVyKMGmOLc4vnFyj4TQpFcbgls9orrtZpCSYGZj8INfZVK05ZI2SSn
         lXjXeUec22U/ZN0jNrQdwzerf/xekkRKjKXYM72PbJOzUQZwy7N9q6BKA60FRoGpUqER
         trzw==
X-Gm-Message-State: APjAAAU8Iq6fDmGIih55HuSvjuCO/WOqXzorPXaSlzdo3CLsF7IG6tRO
	ACV7HK+pAZeZtkZfAIObr1WLB5p+at+Jw7L3cjEUP/p751KwkseeU4pJnJ8BowH9SeKZEFtZ2W9
	PC/88kacnRhLa8amrzkIX2HTziYEHFpldMiWPSiCafzQC83Ym/Kad22piJFu5QIGMSg==
X-Received: by 2002:a37:9fc4:: with SMTP id i187mr25145827qke.141.1553615033867;
        Tue, 26 Mar 2019 08:43:53 -0700 (PDT)
X-Received: by 2002:a37:9fc4:: with SMTP id i187mr25145747qke.141.1553615032688;
        Tue, 26 Mar 2019 08:43:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553615032; cv=none;
        d=google.com; s=arc-20160816;
        b=L+R1tZdeWAAmDNc/X3a9VGxmApOBantbowOfaFLN33CDQmGkFhM+lplPpAYFyi8i1P
         M8HtKF9c0p5Mvz9dZgDYMAG8dUdujfAos84m5XpBTeY+wWbN7QwHlhS44IyhookMNaz7
         KooOpfzLZu2JM/Cl+QcPvGeFSMYNjF5KgzLxmNl7EcwywVbiWd63+lzGjmW2cBngpwVW
         W3/jvUKPpQiorRvxXovxqxqdqZB2mVUGnxELRVBC3lSAjqDhFOnMlhjy4XImHP8aGI6t
         mzsArZ9M4UIEwFEjPd4eJk2bP/FsgLjcZ+nVuELaTan67BNnzzpTX1Rh1u/NI6oMhfY+
         Kdfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=xPwO+VfBDlBl+yGZj+3rGMuEeXiQlCjRxp+hpH3Hq0A=;
        b=osB/R/9Z5pGgueSqCMY1zGPsyvPMtc2r+0uaVTCyAQPBgfSFQAiNmiAYszyBX7YoUp
         FbZ5cbOsuAMAoV29nppOKvCq6yw2Hr8mV2LbL4j4thAMhG3V535xq4YeyyKdU7Fu4vB4
         ZLYmZ6ig+xq389lh7RYiYqGQa8YOjnI2/JgH5iRs18WhNZqwvVJuyV4qZHAl3SkcGwwa
         2vQP2BJrM6vTh2AMMvoVHYerRUe1iVXG9lERhr+tWT5Yc6Mccg/kLw7opM/TGTVSgQYg
         VhK1KavSoHMxbD2yV2dE4xbEim+Tzz+aDYNd65QFvKC2nLZODhoPA+ERICJC7s2+8Kjz
         3ZHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=UnRUcSI4;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k26sor336301qtf.56.2019.03.26.08.43.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Mar 2019 08:43:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=UnRUcSI4;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=xPwO+VfBDlBl+yGZj+3rGMuEeXiQlCjRxp+hpH3Hq0A=;
        b=UnRUcSI4TZIx2r78mB5JigJyEu6np6Ud0wXDTFslg5/OmfzMRXniVE4SYCONHcDC8y
         tMMLUKfmTGK3huEJJ36MrE7QswyLaZU+qXbNMvpmrjMu8S0Nupb/xdxL0+NRuMJL9CAG
         vFgxFzh/865BZvaIKY2fmmfEIQY/oLpQMueoAcMThpgZJiCAZtgZs8Vh7yF5dwOqvABO
         0g57MnHGvalTW98+FNHl9MpnGuv1g2kkB9VOAW5f59Pitfdnep4R+ZtywZNVtdgDtC/n
         XILDCURc37mtovGtcED9cavYh91iZ1DcRowoKJ6YAUpwMUNi/zRI6Od0qBIKw2QZjxlX
         5dGA==
X-Google-Smtp-Source: APXvYqy045SWSJFO/BHLfG05yG54W7e+a05pC6xI7btFS93LrCM/yf9exjaxjN8VsQFaqDmh6vYDfQ==
X-Received: by 2002:ac8:2ed4:: with SMTP id i20mr25830138qta.52.1553615032240;
        Tue, 26 Mar 2019 08:43:52 -0700 (PDT)
Received: from ovpn-120-94.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id j93sm7528547qtd.82.2019.03.26.08.43.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 08:43:51 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: catalin.marinas@arm.com,
	mhocko@kernel.org,
	cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH v3] kmemleaak: survive in a low-memory situation
Date: Tue, 26 Mar 2019 11:43:38 -0400
Message-Id: <20190326154338.20594-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Kmemleak could quickly fail to allocate an object structure and then
disable itself in a low-memory situation. For example, running a mmap()
workload triggering swapping and OOM. This is especially problematic for
running things like LTP testsuite where one OOM test case would disable
the whole kmemleak and render the rest of test cases without kmemleak
watching for leaking.

Kmemleak allocation could fail even though the tracked memory is
succeeded. Hence, it could still try to start a direct reclaim if it is
not executed in an atomic context (spinlock, irq-handler etc), or a
high-priority allocation in an atomic context as a last-ditch effort.
Since kmemleak is a debug feature, it is unlikely to be used in
production that memory resources is scarce where direct reclaim or
high-priority atomic allocations should not be granted lightly.

Unless there is a brave soul to reimplement the kmemleak to embed it's
metadata into the tracked memory itself in a foreseeable future, this
provides a good balance between enabling kmemleak in a low-memory
situation and not introducing too much hackiness into the existing
code for now.

Signed-off-by: Qian Cai <cai@lca.pw>
---

v3: Update the commit log.
    Simplify the code inspired by graph_trace_open() from ftrace.
v2: Remove the needless checking for NULL objects in slab_post_alloc_hook()
    per Catalin.

 mm/kmemleak.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index a2d894d3de07..239927166894 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -581,6 +581,17 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 	unsigned long untagged_ptr;
 
 	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
+	if (!object) {
+		/*
+		 * The tracked memory was allocated successful, if the kmemleak
+		 * object failed to allocate for some reasons, it ends up with
+		 * the whole kmemleak disabled, so let it success at all cost.
+		 */
+		gfp = (in_atomic() || irqs_disabled()) ? GFP_ATOMIC :
+		       gfp_kmemleak_mask(gfp) | __GFP_DIRECT_RECLAIM;
+		object = kmem_cache_alloc(object_cache, gfp);
+	}
+
 	if (!object) {
 		pr_warn("Cannot allocate a kmemleak_object structure\n");
 		kmemleak_disable();
-- 
2.17.2 (Apple Git-113)

