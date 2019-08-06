Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCEE7C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 17:25:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 917032075B
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 17:25:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="PazcMOEE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 917032075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D71616B0008; Tue,  6 Aug 2019 13:25:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CABDE6B000A; Tue,  6 Aug 2019 13:25:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD6BD6B000C; Tue,  6 Aug 2019 13:25:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7E72C6B0008
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 13:25:57 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id m16so50033927otq.13
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 10:25:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=6beAYrbmjek/m+Is/s8mOMW8AHrNTc8IovGO2vElIgA=;
        b=YJfmBnrcvcQljgl48E/2DUO2scjTFkPO1e4WPli2KSLT1p9z21iqlWQ13caATDfXcS
         dKOgGxBZAYGTnG1yQPlGfGRLo3AO/0qZyb0Pj1zsxOt1f9r/HsmLoDRAgWBurMf8J1e0
         M10H9L0qO/NeS7sxMVo39cD+EevHrjZR97WOWzN5oGpUy9owvKCkJDYrt0w2UdRkLLWX
         ll8o48gRCnNpakwcpy5HqyuToy8WIWDxXLSHilqpQB/0S8yyAPBosodziifNKgnjvGi9
         eHodlLAoqQucmKIyUUCgz7daE9thfbjjd5TCKHM+G2bkX7AZ/LPgsl/G6r72yS1roxeO
         cEsw==
X-Gm-Message-State: APjAAAVdezXYHJkEEkt9nst1d2pbhyreAFfgOUi35OJ+Z/m2icFTSo51
	djAqZVBwNUygrcg4aYbPWVSOK27CMqWppLUYrTjXcZLdc2J5bWz2LfVB0RdkvHj9FkuhvypPSC6
	zhHoyXqlxfr13iSl28QrUkmXKfF2aJUQgChKMyEMzdrnim/g//E6CY0hpAOV7ThqXeA==
X-Received: by 2002:a02:bb05:: with SMTP id y5mr5275551jan.93.1565112357179;
        Tue, 06 Aug 2019 10:25:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwT/GUU5gRFoWwvfp+cxF12Ew3zNdUUxkTESXSwSYKhy4aZBhcJi0O3JimWCQZ3xKwcBEHi
X-Received: by 2002:a02:bb05:: with SMTP id y5mr5275409jan.93.1565112355135;
        Tue, 06 Aug 2019 10:25:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565112355; cv=none;
        d=google.com; s=arc-20160816;
        b=LDzPtvmzN1g3Qe88HCd/BmW1kt+t52mVVQD/0nZH8WCQEJF2/PbmrXgulzJR196mHG
         L2mrx+AHwV3E2ybchXROYJhKCvhbChVKFiB64Z4GgFrg6Oxsn5Cj+Ks+l1BvIk8WKXuC
         S7vNVg96I9fyIk9J5gokbgV2aw0zX8q3UCqua+jqCgeZCegXPwaexvDPuXqA8y2d8/iX
         KiJ9ppr7E0dnZcafSDbBLi08R6Q6gGzdnlA3AIXKyIZK2AEQMde2NCqwMSWgyrqYiH3x
         7QqjkRzdOP5u/SLFnCWFkjXfKQz3nfR/B85VepbYPCWdMWywq9d2eR21DTfQTPSZnKhN
         uVxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=6beAYrbmjek/m+Is/s8mOMW8AHrNTc8IovGO2vElIgA=;
        b=tvWe5YDH6L4oJWXIg+JrtRsOd9Ugpw5gWIgxwYDAazybkyFC8CwEUVfdH+s1j3Zp3p
         BXT43CkQGgmxCaYk45g8C3ZMlSjdq0PwT/2k1Ec9Bd7177voHFQ+/6aCjTVXhl4VnycC
         olVO+PjrQRkZOe3t9ykQbJ94Rr/9aJRxIE6IwHnerygnit/GYghV1dc+n4gDS96BsBe5
         vtZASfZKnYhLakFl9j6FPtLjawQRApepuavZ9ob3YZFmHpSNnHr4wOQemGbgCnR2s16W
         QqAALWLnPmjCw7aimUaMr6F57x5Y1LweGIj4Tbu/3kFUQfPbFJmVduiMxhsIzTgm4htO
         /HvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=PazcMOEE;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id r18si109053904jai.47.2019.08.06.10.25.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 10:25:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of jane.chu@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=PazcMOEE;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x76HA2qh161644;
	Tue, 6 Aug 2019 17:25:51 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id; s=corp-2018-07-02;
 bh=6beAYrbmjek/m+Is/s8mOMW8AHrNTc8IovGO2vElIgA=;
 b=PazcMOEE9N/+UfvOtERu+QgGIGJm8qQEDZNLMrHh+cvg6t/3913s67oBcJ4q4MktHPfj
 33Y5QwMfrfKmQzWH4KCHBY5dPYr7FQMutII8TjoCK/VCX3bB9EcWUbSXwLpjDAMIjcjQ
 QbK6Myrv5SDA9n5HKTiJwdOez6HjkOO0hAAKwVKEgU4D/h50lT1QjBpR0aYnI5/psi07
 +bbXAMIjcKym7mE3IE52Bk8wIdmT9j1x2XltzOF4l2TxS2TjLPRcFWNd9bk3q4tR/ZhE
 TGUTEwcUjDk75SzFy60OKwug5ZL7zodpdW1SwBJXATr1Y3h+ZxM0SzYFfXmt0UQY9arx sA== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2120.oracle.com with ESMTP id 2u527pqgqm-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 06 Aug 2019 17:25:51 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x76H8OCf120521;
	Tue, 6 Aug 2019 17:25:51 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2u75bvpga5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 06 Aug 2019 17:25:51 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x76HPotX004263;
	Tue, 6 Aug 2019 17:25:50 GMT
Received: from brm-x32-03.us.oracle.com (/10.80.150.35)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 06 Aug 2019 10:25:50 -0700
From: Jane Chu <jane.chu@oracle.com>
To: n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: linux-nvdimm@lists.01.org
Subject: [PATCH v4 0/2] mm/memory-failure: Poison read receives SIGKILL instead of SIGBUS issue 
Date: Tue,  6 Aug 2019 11:25:43 -0600
Message-Id: <1565112345-28754-1-git-send-email-jane.chu@oracle.com>
X-Mailer: git-send-email 1.8.3.1
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9341 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=974
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908060156
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9341 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908060156
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Change in v4:
 - remove trailing white space

Changes in v3:
 - move **tk cleanup to its own patch

Changes in v2:
 - move 'tk' allocations internal to add_to_kill(), suggested by Dan;
 - ran checkpatch.pl check, pointed out by Matthew;
 - Noaya pointed out that v1 would have missed the SIGKILL
   if "tk->addr == -EFAULT", since the code returns early.
   Incorporated Noaya's suggestion, also, skip VMAs where
   "tk->size_shift == 0" for zone device page, and deliver SIGBUS
   when "tk->size_shift != 0" so the payload is helpful;
 - added Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Jane Chu (2):
  mm/memory-failure.c clean up around tk pre-allocation
  mm/memory-failure: Poison read receives SIGKILL instead of SIGBUS if
    mmaped more than once

 mm/memory-failure.c | 62 ++++++++++++++++++++++-------------------------------
 1 file changed, 26 insertions(+), 36 deletions(-)

-- 
1.8.3.1

