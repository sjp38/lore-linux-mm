Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CA84C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:35:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0738C222A4
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:35:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0738C222A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F74A8E0002; Thu, 14 Feb 2019 05:35:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A5CD8E0001; Thu, 14 Feb 2019 05:35:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64C298E0002; Thu, 14 Feb 2019 05:35:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 10C438E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 05:35:26 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id p86-v6so1493641lja.2
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 02:35:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state
         :content-transfer-encoding:subject:from:to:date:message-id
         :user-agent:mime-version;
        bh=Qvt3ii7WGQ2Aa/PXSP0sxNY2frpAsNaxx5wTCLiVjrE=;
        b=IEwXnpKSgFJBDaDbqGyK5pcrJehG63JoRo/ynQt5otZxxd2Hv94JiXfMIOz7BoKlcf
         NR/Y0a9EelOX+ievyV1dGhMg4MQqphEeaGmcrgHdY8mt/97yuTxjU9rClMFDN6O510TS
         GabfIgMO15Dnr77lUb+zI8SOMsI7G3SEpUS1GgssZWDGprfdbhSy2wNM0o8mtqa5jTTv
         GYK9akb5bu9OQmInvR0wdIy3zNEik1MPuQr6Dgh8CYikjmlM8DinJ1XJqtw0H+E0Ixor
         71ecBBgPZ/i1r3/wVorYn5XgtgVmrd+WSj+VH5K3gp6mXa3KaSsE9Yh6P656EzstaZeo
         c40Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAubjCoudrPLMi58BSrTZNntzC+YGFpMWbtZUwDrnj35C71S6lF9r
	sNtAufa5DaiU8Hd34faQYCro2ErMlccS4LIrMEWu5CJyyiVpz95N70TA87N32l1AJx1ldPXPAx3
	J8fIeOdjeGtWiHkVwQXxmXuCVIiiCWz+up9TSzgDtOAv86X5H7l+PJlbZLE/9nIRR5A==
X-Received: by 2002:ac2:53b7:: with SMTP id j23mr1825027lfh.109.1550140525472;
        Thu, 14 Feb 2019 02:35:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaMLnrV6difJO/44PUHIiKqzfmtRDLXetLk1ytUMUpTaOW1A2IkKVdzriQNcKezSLvrrdh3
X-Received: by 2002:ac2:53b7:: with SMTP id j23mr1824978lfh.109.1550140524468;
        Thu, 14 Feb 2019 02:35:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550140524; cv=none;
        d=google.com; s=arc-20160816;
        b=cxvhKwuSJByPIF/NvYRq+OUnQGO6EUP92BmFgmT8U8obJBAz9dlHn3p0wkpmYImmPN
         Mw8IaPy5PdEatsOOkz/iAKQv3ymmoh+hAhtBJaDlHBEteiko0ecx6UjuAe0rI9G0fhdc
         pnh9qqFPn36ra7G3TItIrabI05aOC9gDg/Jky7MKCyBUhU1eS3Bke3DC/KLNCGk0h2Q/
         4OS/YFphguqRLVBtjvwLVLNI+6BGPv8kZMBtioubkq+c7hHLcgVFWsFbrPtlKvhpqkvP
         Yp8gssACO3/DSvoSeQhzNvfLDVjM9YSk7Phkc5I378Ukdk/AX/mcAP5QbyG8DSv4pY4o
         KG2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:date:to:from:subject
         :content-transfer-encoding;
        bh=Qvt3ii7WGQ2Aa/PXSP0sxNY2frpAsNaxx5wTCLiVjrE=;
        b=kYOuzdt99arng6L1t3EGILbuYFe8C+qfRfLRth2v409Ho0qVWoHuUkzUh4+PFgO1xK
         KPo+xGRMKzrz4necDoD4tpbPEpsdE/mobOzEzcwJgq4q1Vw4hkdAbPP4Ubjpw6UraYmi
         NqA0BE1+HWxQDS+DAByRp4ZX3oAzFcwoHjgmTfvMP4mCO1wFy9rl8hA+axppbtxw4iKp
         mz7P+729MRr+95a/TRRWWRzbI7hc9oI2YVO7UfIkk/Blh2eeld6l5wNEQxBcZ13VbseC
         yOAp3zPnXb0B5jLnO7ClthNrux9o0dYGs0TYmScCuMBwWG8xnaDRReM25PnyybZrRDh+
         1wgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id t11-v6si1869111ljd.108.2019.02.14.02.35.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 02:35:24 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1guEMO-00052x-6L; Thu, 14 Feb 2019 13:35:16 +0300
Content-Transfer-Encoding: 7bit
Subject: [PATCH v2 0/4] mm: Generalize putback functions
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, daniel.m.jordan@oracle.com, mhocko@suse.com,
 ktkhai@virtuozzo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Thu, 14 Feb 2019 13:35:15 +0300
Message-ID: <155014039859.28944.1726860521114076369.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Functions putback_inactive_pages() and move_active_pages_to_lru()
are almost similar, so this patchset merges them in only function.

v2: Fix tracing. Return VM_BUG_ON() check on the old place. Improve spelling.
---

Kirill Tkhai (4):
      mm: Move recent_rotated pages calculation to shrink_inactive_list()
      mm: Move nr_deactivate accounting to shrink_active_list()
      mm: Remove pages_to_free argument of move_active_pages_to_lru()
      mm: Generalize putback scan functions


 .../trace/postprocess/trace-vmscan-postprocess.pl  |    7 +
 include/linux/vmstat.h                             |    2 
 include/trace/events/vmscan.h                      |   13 +-
 mm/vmscan.c                                        |  148 +++++++-------------
 4 files changed, 68 insertions(+), 102 deletions(-)

--
Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

