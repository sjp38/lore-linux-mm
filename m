Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9295AC10F02
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:21:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58935218AD
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:21:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58935218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EFC118E0006; Mon, 18 Feb 2019 03:21:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E85A18E0001; Mon, 18 Feb 2019 03:21:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D73B38E0006; Mon, 18 Feb 2019 03:21:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 684788E0001
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 03:21:08 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id v4so187756ljc.21
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 00:21:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=UDYt67lC/nUEnY97sYoZYYeAB57EoEaThBbl3sDwSL0=;
        b=OU3DOkLxNZII5l8asVQm1jeKd7YxxzxUdjmIDtZ171oOuExZIvEsL3u3oLAJLwIERY
         k0AWewbWepBVQjJiMR7z6W7eJuQTStqvU1HOg2W8R+1zFuofuYRWgG7koP32o6S6M8MR
         1j35TDuvEWQXmSSMDDAM6Nl2gjYNvAnGjRXFY8TgjK0GoFRDun24w9b2Z8M7H5yVT60+
         LVYF3TrcEzUPjormsDOo7TxnyF462inNlH6bODZbqnRTXpa4Ea98k+mu/anyrvNDdPg5
         kKfz9UYxlZ19H6qGYn37XghDHiFZvzJObCx9LJ9b9aen1dD3fbRDWFJ5YFP+VucjKHRb
         2c2g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuY2LKofkEdrf7Y5GmwkUm+ZVeYflRxnMOh196ZmiUbcdMFd/HoW
	ckd+PKb1lkSooFODifsIH1BpJPE/hOi4VqW+FYHQmjFfrCH923+TJs3kLjnyl1BeKN1nZ/V00YI
	s4WiEcUYivYR3CedqMlEqTMskLfOB/4PZ1w+XJE05AEMrnlKFUSeRo61xukgVcujXSg==
X-Received: by 2002:a2e:9a8b:: with SMTP id p11mr13264950lji.66.1550478067779;
        Mon, 18 Feb 2019 00:21:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbG0yRnrzUYP355WbCvYKgNUXKQLfovpOrV4PCdUTlOCYqGn4KWFHhtGGjgvYoNms45Hpdr
X-Received: by 2002:a2e:9a8b:: with SMTP id p11mr13264909lji.66.1550478066744;
        Mon, 18 Feb 2019 00:21:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550478066; cv=none;
        d=google.com; s=arc-20160816;
        b=DUF7FlyGgVw14/S/yZyMcib/n3Os9pzhz243NcX68+IX5Rm/96UhGfWsTTsDgNV58n
         ZhAA2Ehv0JdjFl0P4xWj+oHaf+eR7uhr33C6FcBNTiH5sz+WbU4XnEQMura1U4K01v03
         FWhAawjlw8G21Jpddni08Xkex+vI2NXizP7PTnZU38B+ZUDXHv1TeOkOEgisMw/HOK17
         9QpasFxPAHWLhepVVJ8GduI8GND4V2KGq8wOgjd2jDh5uLg/A+N+TI/L/hSYhUc31Xb5
         x0SQMDqEfB2TsyeY/6Eo0mjHgd5EtQBIGyaEuJJdVJBk6MVN1uxiGV0WkeJgRks54wCQ
         BXpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=UDYt67lC/nUEnY97sYoZYYeAB57EoEaThBbl3sDwSL0=;
        b=Oi/ouaMBSDBcuOW1fyyUwHCRYNqJzOH2SG5JZ67Dv8Gh8pHduo4AxtYPY4pUW+OR3c
         Ce7bwdLpPS/kEDhwt1LFPZuw8ZtAwMlVHPFpxO45pQ5pc+oOCbCp0QFsktBcqCN98yoM
         xujlO07VHrEPwL0TUK6MEg4f0lvALUqNcnhTia28bScV3wFeFs5obi6fcKjwOUfQv25k
         x6d/9MC5JBApemAVqtfINQO/aGYn8N9+qFiUgEzKWKcxy7QeQOMS7HC2uqecmWaUjnt/
         Tmp81G4JzWRBk8EpTURp62y9bj0vx1Zy7uALg6W3xUt7ZEaGYhsluBJ7o/kpxQJRfuG4
         qP+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id g14-v6si9827874ljk.201.2019.02.18.00.21.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 00:21:06 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1gveAZ-0007pa-FX; Mon, 18 Feb 2019 11:20:55 +0300
Subject: [PATCH v3 2/4] mm: Move nr_deactivate accounting to
 shrink_active_list()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, daniel.m.jordan@oracle.com, mhocko@suse.com,
 ktkhai@virtuozzo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Mon, 18 Feb 2019 11:20:55 +0300
Message-ID: <155047805525.13111.10290320587729090284.stgit@localhost.localdomain>
In-Reply-To: <155047790692.13111.18025172438615659583.stgit@localhost.localdomain>
References: <155047790692.13111.18025172438615659583.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We know which LRU is not active.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 mm/vmscan.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 84542004a277..8d7d55e71511 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2040,12 +2040,6 @@ static unsigned move_active_pages_to_lru(struct lruvec *lruvec,
 		}
 	}
 
-	if (!is_active_lru(lru)) {
-		__count_vm_events(PGDEACTIVATE, nr_moved);
-		count_memcg_events(lruvec_memcg(lruvec), PGDEACTIVATE,
-				   nr_moved);
-	}
-
 	return nr_moved;
 }
 
@@ -2137,6 +2131,10 @@ static void shrink_active_list(unsigned long nr_to_scan,
 
 	nr_activate = move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
 	nr_deactivate = move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
+
+	__count_vm_events(PGDEACTIVATE, nr_deactivate);
+	__count_memcg_events(lruvec_memcg(lruvec), PGDEACTIVATE, nr_deactivate);
+
 	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&pgdat->lru_lock);
 

