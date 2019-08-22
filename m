Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CB97C3A5A2
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 06:21:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02B9E20870
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 06:21:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ucr.edu header.i=@ucr.edu header.b="WhpAJMmU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02B9E20870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=ucr.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69DCA6B02CD; Thu, 22 Aug 2019 02:21:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64EF56B02CE; Thu, 22 Aug 2019 02:21:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53BA56B02CF; Thu, 22 Aug 2019 02:21:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0189.hostedemail.com [216.40.44.189])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3756B02CD
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 02:21:54 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id A67C88248AA1
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 06:21:53 +0000 (UTC)
X-FDA: 75849068106.07.vest74_84cd12071d609
X-HE-Tag: vest74_84cd12071d609
X-Filterd-Recvd-Size: 6600
Received: from mx3.ucr.edu (mx3.ucr.edu [138.23.248.64])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 06:21:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=ucr.edu; i=@ucr.edu; q=dns/txt; s=selector3;
  t=1566454913; x=1597990913;
  h=from:to:cc:subject:date:message-id;
  bh=te6sDAmETT+7Bh5fmhANTjsc/hBDg1ooMbPzRFeOAW8=;
  b=WhpAJMmU9En7p+63s6roHZ0R+/lY8IP9EN/v3Est3+LJPcgcpnw+XR1I
   GRbWsozEvXDISB7WNkirCMP/4UDFPKp2kJZGeTPbdJ4W+8I9UVCsHeL6L
   ad3QXSm3fBj8P59eQ1aKXo9CHhYu0ukaYBWPebfrWsXP3sbLDjeGmOunk
   h+s/TvyXWGSAwphWz+7HgT1RrP9D5/GlnOT/ztBtTaBCCubOyBpPnwG40
   GHDbDfJikiQK/Tu5jrSJFA6EjKiNOjG9os2p2knydbBhvL0/vsiKi3b5c
   4ctqGeIyztsE7zIJSqy8XnGoG/nmWSn7m2qiuS1InEFQj0f5/z99ZsKzU
   Q==;
IronPort-SDR: otY4eEvu6Y7Jq4gwQBTcjfAZy3XPcjP4LJ+KSYwoD5UvSLRHOmkogzRrvovLFwksypD9s/fFMl
 TMXFQeqBfFWqw2JMcIIOGIcDDz/tgwOC0jrculNlpiiV7ODJ8L5j9EjAgwPGNqiSdWMRCKb56L
 qb1ph/4e/JRHN8bn0wvZxzjXSSO8bvjMGhSE9bMs9Hr1Yhm0DX602cVIgbLJhm21CPcOz6JZCT
 iy1zTQG8tg8SH9DB9ZnGREVShXpqOstAatUdE8llo8I29u7Ai2H473g/Lxo4+wMWgBXhfuHwob
 kEY=
IronPort-PHdr: =?us-ascii?q?9a23=3AsWapjBTCrOKwlxYf4Dv+i3rApdpsv+yvbD5Q0Y?=
 =?us-ascii?q?Iujvd0So/mwa69YxON2/xhgRfzUJnB7Loc0qyK6vqmADBcqs/Z4DgrS99lb1?=
 =?us-ascii?q?c9k8IYnggtUoauKHbQC7rUVRE8B9lIT1R//nu2YgB/Ecf6YEDO8DXptWZBUh?=
 =?us-ascii?q?rwOhBoKevrB4Xck9q41/yo+53Ufg5EmCexbal9IRmrswndrNQajIRtJ6o+1x?=
 =?us-ascii?q?fFvnhFcPlKyG11Il6egwzy7dqq8p559CRQtfMh98peXqj/Yq81U79WAik4Pm?=
 =?us-ascii?q?4s/MHkugXNQgWJ5nsHT2UZiQFIDBTf7BH7RZj+rC33vfdg1SaAPM32Sbc0WS?=
 =?us-ascii?q?m+76puVRTlhjsLOyI//WrKkcF7kr5Vrwy9qBx+247UYZ+aNPxifqPGYNgWQX?=
 =?us-ascii?q?NNUttNWyBdB4+xaY4PD+saPeZDron9oVQOpgagCwe1GejvxD5IiWHy3aInzu?=
 =?us-ascii?q?8tFQ/L0BAlE98IrX/arsj6NL0KXO610qfG0DvNYfBR1zrm9ITEbgosre2WUL?=
 =?us-ascii?q?5sbcbcz1QkGQPfjlWXrIzoJzGa1uUMsmib8upgUv+khmknqgBwojig3MYshp?=
 =?us-ascii?q?XVio8b0V3E6Dl2wJwvKdKmVUF7fMepHZ1NvC+ZL4t7Wt0uT31stSogybALuY?=
 =?us-ascii?q?S3cDYXxJg73RLTdviKfoqQ7h7+VeucJS10iGxrdb+/nRq+70mtxvf+W8S71l?=
 =?us-ascii?q?tBszBLncPWtn8X0hze8s2HSvxg8Ui/wTuPzAXT6v1cIUAziKrbN4Ytwr4umZ?=
 =?us-ascii?q?oXtkTOBir2l1/3jK+Sb0kk4uao5/n+brXou5ORM415hhvxMqQpncy/DuA4PR?=
 =?us-ascii?q?YUU2eH/uS80aXv/Uz/QLpUkv07irfVvIzeKMgBpaO0AxVZ3pg+5xqjFTuqzd?=
 =?us-ascii?q?AVkHsfIFJAYh2HjozpO1/UIPD/CPeym1StkTZrx//cP73tHonBI3bYnbf8Yb?=
 =?us-ascii?q?l98VRQxxQuwtBC/55UEK0OIOrvWk/ts9zVFhs5Mw2yw+b6B9Rxz4YeWWeUD6?=
 =?us-ascii?q?+aLqPdq0OH5uE1L+mLfo8Vt2W1BeIi4qvfjG05hFhVKbi73ZIWMCjjNultOQ?=
 =?us-ascii?q?OUbWe60YRJKnsDogdrFL+is1aFSzMGIinqUg=3D=3D?=
X-IronPort-Anti-Spam-Filtered: true
X-IronPort-Anti-Spam-Result: =?us-ascii?q?A2GYAAAFNF5dgMXSVdFlHgEGBwaBVAg?=
 =?us-ascii?q?LAYNWTBCNHIZTAQEBBosdGHGFeIMIhSOBewEIAQEBDAEBLQIBAYQ/gmAjNQg?=
 =?us-ascii?q?OAgUBAQUBAQEBAQYEAQECEAEBCQ0JCCeFPII6KYJgCxYVUoEVAQUBNSI5gkc?=
 =?us-ascii?q?BgXYUnGaBAzyMIzOIeAEIDIFJCQEIgSKHFYRZgRCBB4ERg1CEDYNWgkQEgS4?=
 =?us-ascii?q?BAQGUNJVvAQYCAYILFIFvkj4nhCyJFIsHAS2lPAIKBwYPIYExAoINTSWBbAq?=
 =?us-ascii?q?BRIJ6ji0fM4EIiQ6CUgE?=
X-IPAS-Result: =?us-ascii?q?A2GYAAAFNF5dgMXSVdFlHgEGBwaBVAgLAYNWTBCNHIZTA?=
 =?us-ascii?q?QEBBosdGHGFeIMIhSOBewEIAQEBDAEBLQIBAYQ/gmAjNQgOAgUBAQUBAQEBA?=
 =?us-ascii?q?QYEAQECEAEBCQ0JCCeFPII6KYJgCxYVUoEVAQUBNSI5gkcBgXYUnGaBAzyMI?=
 =?us-ascii?q?zOIeAEIDIFJCQEIgSKHFYRZgRCBB4ERg1CEDYNWgkQEgS4BAQGUNJVvAQYCA?=
 =?us-ascii?q?YILFIFvkj4nhCyJFIsHAS2lPAIKBwYPIYExAoINTSWBbAqBRIJ6ji0fM4EIi?=
 =?us-ascii?q?Q6CUgE?=
X-IronPort-AV: E=Sophos;i="5.64,415,1559545200"; 
   d="scan'208";a="76358207"
Received: from mail-pf1-f197.google.com ([209.85.210.197])
  by smtp3.ucr.edu with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 21 Aug 2019 23:21:51 -0700
Received: by mail-pf1-f197.google.com with SMTP id b21so3327514pfb.17
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 23:21:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=8jiYykEIKY+vErKJnS6hI8dD2/3tnco1PA9iNXuAOYk=;
        b=qbWtMUt419DPWvvLUu3HIBmSl5mAZHVDz8kvGUiqnIYmZmIH54MKMx/+r9puo8HwLj
         /5ey2F0N9XxpzXaZ/KuIX02fIboVm7hDQV2jm5nz4B/ImMHVPjSChurME0S8vgdzzqvO
         ZvjFouhY0Zip27ePmkLLpdhc7qMj5qYsdRaYIOu36zQnW7Q+Ao0vf++ZevF66/RFMEkJ
         XiQlurzmUe/Xiru2NLESHDvC9UYz5Zr9pHJjsOjawpDJsOssqMbsnNwVSKVgqCLf2oXo
         2M8e15+gTLp02XLox0LFfBZWyeC3U6MKMmFCLETsSNgLw6Cc8xtaa6jbhZYlil7VTvrJ
         RTeg==
X-Gm-Message-State: APjAAAWaQx8jj+DFE8Q7NnW+nG7pmdpyesXzlZ/ZxcbCXzlBOYrdmkyX
	yK/IQNPTDHhpSys8Zst0hyOGvPYKKENGettulOXbCXM8obY7c17Aho5gWyUZKwOa5piUCDv68sb
	Bdsrw+0E4b6Cn
X-Received: by 2002:a17:90a:4c:: with SMTP id 12mr3675058pjb.40.1566454910364;
        Wed, 21 Aug 2019 23:21:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPagb0bDHT1I4Z/sKRwM+ZNsKDqjx+3do3M12tj3N4RR0xguVlX5L/h68YeOUt+IBeLNfJ5g==
X-Received: by 2002:a17:90a:4c:: with SMTP id 12mr3675033pjb.40.1566454910065;
        Wed, 21 Aug 2019 23:21:50 -0700 (PDT)
Received: from Yizhuo.cs.ucr.edu (yizhuo.cs.ucr.edu. [169.235.26.74])
        by smtp.googlemail.com with ESMTPSA id b123sm44863606pfg.64.2019.08.21.23.21.48
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 21 Aug 2019 23:21:49 -0700 (PDT)
From: Yizhuo <yzhai003@ucr.edu>
To: 
Cc: csong@cs.ucr.edu,
	zhiyunq@cs.ucr.edu,
	Yizhuo <yzhai003@ucr.edu>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	cgroups@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm/memcg: return value of the function mem_cgroup_from_css() is not checked
Date: Wed, 21 Aug 2019 23:22:09 -0700
Message-Id: <20190822062210.18649-1-yzhai003@ucr.edu>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000460, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Inside function mem_cgroup_wb_domain(), the pointer memcg
could be NULL via mem_cgroup_from_css(). However, this pointer is
not checked and directly dereferenced in the if statement,
which is potentially unsafe.

Signed-off-by: Yizhuo <yzhai003@ucr.edu>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 661f046ad318..bd84bdaed3b0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3665,7 +3665,7 @@ struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(wb->memcg_css);
 
-	if (!memcg->css.parent)
+	if (!memcg || !memcg->css.parent)
 		return NULL;
 
 	return &memcg->cgwb_domain;
-- 
2.17.1


