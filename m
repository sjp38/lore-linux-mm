Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53490C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 04:37:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E400D2177E
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 04:37:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sK/WGZsL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E400D2177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38DF68E0003; Wed, 13 Mar 2019 00:37:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 33BCC8E0002; Wed, 13 Mar 2019 00:37:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22D458E0003; Wed, 13 Mar 2019 00:37:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D77788E0002
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 00:37:15 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id w4so796554pgl.19
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 21:37:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=vvcJ932HmjiNLvAMSePA/fFxFWO8r6DbaJzWbSrEQEw=;
        b=FZlQ5OabrbeNjjlSKO14lj2DBwyuPQcaYFUCZECkdPZa2quT18S1IZ5fb0O/YFR5Bq
         8V+xFVxw1PsEMgohaBw2kNnffGSfs1Cw1nI3Rj6sygJ9QWaU4EhfVNHuOg2SRNoPgOb/
         yvnY/gNXRsnQXWq6ceSZbiu/CLVEhK39kX/QTSPTr7M0dgiHL5H//DZpGXaF7A2Utlct
         lHWJNXGJnaXrDn+JKBPYHs1SP4rOoDTNaBh91CiM11m1um86Dt/dJmvY5ABLelOP0ifi
         2bdRA7K+aTFnqciYzgcJUzJ7trouqdIx31JDlKKXqRAjTByZr2/3yt3SpiqPbo0AO8gc
         sUKQ==
X-Gm-Message-State: APjAAAWJcxdVcBzFx2JQifrmUkT3Af1qfsd/xmnrEyjTGUp+oDlaHHUY
	Lf056+BAa3W9GweY67SQl2FQI1Tz5GCqEoZjQdXsC52yZKyw2c+I6Z3tqilYIU79s5Eb+Qeyay3
	UAX49PNib9kKTeAPUSDECDM26hImxXEyeHKnMHfbGABPFmGstSntliGgvNToGztCEOWqwUcgWCp
	d5dnRqrjMhnrnUKlbDapv2/eDurdyT8UP2WBcmcoD9EUKrL76Dp/b5/3J/1yql18wbXLKOUVsX7
	/tvuOcYDM2atpl2JOISbEJ7AQJTxJbHx4O1HvR5cKat1hfpF4Rtb4boJsEVHXUbJ0zN02e/9k4G
	UDsgL5B9GR3kMdO9urPwH03Nut27xkWCpVDOoBu6AiUlh5IdB8ikXHLZZq2d5IZWtpWQcGQJtkq
	E
X-Received: by 2002:a63:6c43:: with SMTP id h64mr36789823pgc.22.1552451835136;
        Tue, 12 Mar 2019 21:37:15 -0700 (PDT)
X-Received: by 2002:a63:6c43:: with SMTP id h64mr36789762pgc.22.1552451833680;
        Tue, 12 Mar 2019 21:37:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552451833; cv=none;
        d=google.com; s=arc-20160816;
        b=n+EWVgyKfFgGOQvPuHFmu2YyDvfJmD74arA8P6G9Ad60Lrpg1qm0AV5bToAfUXGSOQ
         M5OPZh9YYksoPeWCpRi74q/paxyEf0kqLviREZtKV4qcWgCaShrv4Ou4MaaA071sNHkM
         plbVDrmI8oecn9bwUESR9lMCkGhcMzJmW0MlKtj+VZqEdxp5MQdI7tJ7oQBf/2TWRlPt
         7gm09nMWQzjhlr9I850yYxz0UDHOUe8TjPwulho8kV/ErPV4Yv6Jo6Nh5IndJ/rLi7pB
         SixqdTpogtO5V0mvqPvrrlalZXNR5zj3KVCGK1apGtHOIAMX+L5rFSItnIEr/J9PiVpb
         W61Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=vvcJ932HmjiNLvAMSePA/fFxFWO8r6DbaJzWbSrEQEw=;
        b=R3RBUgQyngf8fxFkY7cn9zJMbhaOjPKWIxlTKfgLuCV0qCOu5gYV3+ANS+elSAhZPA
         nhEm/tr4+jaT+pNBS942GL2NhOy7JJltjMlPu8Gl3WQLWDoSEFFSNWH63Zhc4qQmb257
         Fxod+R5KW9BGOaUd2/JlCblxvmYZPuzDXRQyEaU/UBjI8i9vVGQ20JiJ9L6/4V6hNQWu
         VLu+4+cGsVtohrWH1KVRSF2pt2VgGpjGYxSl2CLAznsrjlTW+8w6yYDpV6HrFH8FItTC
         /uo2tmM22qdxXwPZQzXHv5cNhtDgTCvu9aDQLjAtrnQ445ebsAhq4nV7dpqVMh2ooQ2/
         hQRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="sK/WGZsL";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v9sor13540176plo.31.2019.03.12.21.37.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 21:37:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="sK/WGZsL";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=vvcJ932HmjiNLvAMSePA/fFxFWO8r6DbaJzWbSrEQEw=;
        b=sK/WGZsL8KZ3yBsNXjRSX7Np+4o+9qWP78HhXnpAH3BvgtmPnP9t2TUUU5rQIHpLQG
         eB8BduNr2nN8aa/PYAvoIfn5mbMgJWQDsppGPjWTkxQV+K/JSp/3cDlUpv8yUV0ay8Ha
         V6qXZIYgr8t7SGLJqMkqo/TaXorsr0UZiFCmJW4k5k6F+S5eF9zjzxVuFrGuC8Ki7i7u
         WS4VF8t6l+eslSlSfH6thAsW502uaMYWjCoTqOAC4onSSl/Sk/hnaetHSRhS5Ur/JPR4
         pPRrSa6wYIqFJq1SARHMJKTm66Mx5u2T8loZoML1NPKLROKTh1dJSrtI+iNlUR7qnC3A
         ajTg==
X-Google-Smtp-Source: APXvYqzjpFCbiRTXGxBbvSWwLnOPYVDQorjiTkGqMM64xnc6GlGbd0UVZsEzjVpn9ZEmPk+qRPG3Sw==
X-Received: by 2002:a17:902:848f:: with SMTP id c15mr13229993plo.240.1552451833409;
        Tue, 12 Mar 2019 21:37:13 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id n85sm3265329pfh.84.2019.03.12.21.37.10
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 21:37:12 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org,
	linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm: vmscan: drop zone id from kswapd tracepoints
Date: Wed, 13 Mar 2019 12:36:53 +0800
Message-Id: <1552451813-10833-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The zid is meaningless to the user.
If we really want to expose it, we'd better expose the zone type
(i.e. ZONE_NORMAL) intead of this number.
Per discussion with Michal, seems this zid is not so userful in kswapd
tracepoints, so we'd better drop it to avoid making noise.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 include/trace/events/vmscan.h | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index a1cb913..d3f029f 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -73,7 +73,9 @@
 		__entry->order	= order;
 	),
 
-	TP_printk("nid=%d zid=%d order=%d", __entry->nid, __entry->zid, __entry->order)
+	TP_printk("nid=%d order=%d",
+		__entry->nid,
+		__entry->order)
 );
 
 TRACE_EVENT(mm_vmscan_wakeup_kswapd,
@@ -96,9 +98,8 @@
 		__entry->gfp_flags	= gfp_flags;
 	),
 
-	TP_printk("nid=%d zid=%d order=%d gfp_flags=%s",
+	TP_printk("nid=%d order=%d gfp_flags=%s",
 		__entry->nid,
-		__entry->zid,
 		__entry->order,
 		show_gfp_flags(__entry->gfp_flags))
 );
-- 
1.8.3.1

