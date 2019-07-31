Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3852C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:46:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62BE9206A2
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:46:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="FkJBduK7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62BE9206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C8E88E0003; Wed, 31 Jul 2019 09:46:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 079908E0001; Wed, 31 Jul 2019 09:46:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E81FF8E0003; Wed, 31 Jul 2019 09:46:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id C895A8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 09:46:16 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id s9so61623028qtn.14
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 06:46:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=8f2ucm94N3RAHWXp2XYv1ymSM73yXUEwnSMo5qDl8Gc=;
        b=aXpvkHe074R1BTnErMNPxUtqsUWcNpseM1qFBB2BZeXTR+uscYlO+kkhPa1cgaRSbc
         n/LBaubarZ8OR1V6FybY5IEWVfHBHc1bkPGZXnNZ0vNWamsSOwKAXuhxjibVE2LEFgXL
         iB4BDFDZFhgR5rqVs7ItXNNTHM3OoLCpAKsdA4Ai2fJ/20gTZqASxngco4gzIqjpnsLe
         Z19XDr8iEcshmOukOjdGaG4xFLEMdnHwyCa2XRRfNpgUSzRcA4DIc0ln5kV/s3Zt2sNf
         4HIlgUoln/PMlmi2g4gw5n2CwbhGCqJ5P8Yp42vZOot73QpfUWEEHmP5nzj0jECZ0/aH
         uGIw==
X-Gm-Message-State: APjAAAUzuM1R36gPQMWD7bqSg5INdUCS8l8WTBf5Cayvt+bXKXI5noJ2
	du7II4JolNoI7bFytgq5MwBIdyk/DTQSzwjhp3JUrGYAXHZChksFz4neZFxpypFYLdh7DBqyED3
	SAI8wQe23ZbWNdzOobx3W2FDr3UtO7G6+8W5MejL3ZNADFcYxdmwYiro6KmRXscr/PA==
X-Received: by 2002:a37:9dc8:: with SMTP id g191mr81613327qke.431.1564580776604;
        Wed, 31 Jul 2019 06:46:16 -0700 (PDT)
X-Received: by 2002:a37:9dc8:: with SMTP id g191mr81613287qke.431.1564580775992;
        Wed, 31 Jul 2019 06:46:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564580775; cv=none;
        d=google.com; s=arc-20160816;
        b=bTRFSPQEaME38hvZyoC1ebGtpkUHftE6eXmVdOlNRGclMN8W46XbEv4sMwG2YMQ5w4
         bafTUs7D27MrhkhLMRmqptWN8Fakk7zooYbiNoU+9pEsRqsipgo14fTlN5l1+uEt3SFu
         NyZdP7WmX32BRkA2s2HvXnQlzXyup9KrnRxf/SasUm7zeWODmz8H5PHyModk0FoP72v/
         3Q1+Jxkr00FOSFAygTJ61k/iPHwGVDUXpfyaVRHbM/1QXg/68DMfedR5cteqVk52wHgO
         IWyXsgHJ09BusDkNepazu+TlI6uETYN7VlMlSrhlTEwkn+v/RD7zQqVCRUbEiXiHdloZ
         4dlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=8f2ucm94N3RAHWXp2XYv1ymSM73yXUEwnSMo5qDl8Gc=;
        b=Vxuc0yMJVaiPIE4D6siUpE3S9lGbzi+GIid9aw6tWQe/MbFbN/qElapIgGxsLaWNB3
         B4dUvYrBPo7nuVhskVS8KeGNSaX7fq7Ym0TWNqlyt/Dkte22kxxp2bfUsmixIriH6H3U
         MQYW+buYk7zMnThYuwbB/6XribOQ7q8Cc5V7YTi+vP1qYKkkRqjcEeAbZpD6605tsYBM
         Ygj34IKasuieI/x0fqdch7nwXJCn5t30VNTuI32fiIGR2h/QUTWGnDbS0mzzLKZ0YNaq
         nk392NOQxsXQqQgnyNqK5AkB5EiEaAsX36Zs1nvKhI7wyrK4cfj03oXYnj0rp52nHEky
         7h9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=FkJBduK7;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r10sor30163978qtn.47.2019.07.31.06.46.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 06:46:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=FkJBduK7;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=8f2ucm94N3RAHWXp2XYv1ymSM73yXUEwnSMo5qDl8Gc=;
        b=FkJBduK7o2U9DkS56fiFYacXOe0s7mfPx9W0zVWXLGIoBYvxPS2C2Ogl6X1ZM5uZB4
         cNBAvSNVe+z5s06SyzfhFcV2RMEo+4pQRXPG6a+ptBnkhXvLwFhmgz0gt+BJW3wJbihR
         nQ+IC+gD8EKjLqqM8uUq0xBkQAcLq2ShOD+pLbe7omO5lVwVExK79k9jyXMHHP9ALfdG
         HN5osGJO/3roRO/n8DH2DeHGHAjojwdQ4gDaHzxo6r6GRyDbZlbArnEjESad9OoMyJV3
         prsq8zmDCb3fv9cBiBkmI//oNrGrN1yzBD8iF6WSFS37+kW8o3ZD2SB4jdrbHoccKKeQ
         LE/A==
X-Google-Smtp-Source: APXvYqwYN2nhY1spLQvC2zasTrz/bvKwBvV9enaVBBRDKUn7AFldOujCtq9CUvaY4BxZgE1L7GHd6A==
X-Received: by 2002:ac8:2af8:: with SMTP id c53mr88215379qta.387.1564580775668;
        Wed, 31 Jul 2019 06:46:15 -0700 (PDT)
Received: from qcai.nay.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id a67sm31086281qkg.131.2019.07.31.06.46.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 06:46:15 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: miles.chen@mediatek.com,
	mhocko@suse.com,
	hannes@cmpxchg.org,
	vdavydov.dev@gmail.com,
	cgroups@vger.kernel.org ,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH -next] mm/memcg: fix a -Wparentheses compilation warning
Date: Wed, 31 Jul 2019 09:45:53 -0400
Message-Id: <1564580753-17531-1-git-send-email-cai@lca.pw>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The linux-next commit ("mm/memcontrol.c: fix use after free in
mem_cgroup_iter()") [1] introduced a compilation warning,

mm/memcontrol.c:1160:17: warning: using the result of an assignment as a
condition without parentheses [-Wparentheses]
        } while (memcg = parent_mem_cgroup(memcg));
                 ~~~~~~^~~~~~~~~~~~~~~~~~~~~~~~~~
mm/memcontrol.c:1160:17: note: place parentheses around the assignment
to silence this warning
        } while (memcg = parent_mem_cgroup(memcg));
                       ^
                 (                               )
mm/memcontrol.c:1160:17: note: use '==' to turn this assignment into an
equality comparison
        } while (memcg = parent_mem_cgroup(memcg));
                       ^
                       ==

Fix it by adding a pair of parentheses.

[1] https://lore.kernel.org/linux-mm/20190730015729.4406-1-miles.chen@mediatek.com/

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 694b6f8776dc..4f66a8305ae0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1157,7 +1157,7 @@ static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
 	do {
 		__invalidate_reclaim_iterators(memcg, dead_memcg);
 		last = memcg;
-	} while (memcg = parent_mem_cgroup(memcg));
+	} while ((memcg = parent_mem_cgroup(memcg)));
 
 	/*
 	 * When cgruop1 non-hierarchy mode is used,
-- 
1.8.3.1

