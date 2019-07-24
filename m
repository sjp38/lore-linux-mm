Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 407FEC76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 22:35:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEFFF21850
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 22:35:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="WTZ94cyv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEFFF21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 829C06B0273; Wed, 24 Jul 2019 18:35:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DAFC8E0012; Wed, 24 Jul 2019 18:35:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C9CB8E0002; Wed, 24 Jul 2019 18:35:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4C6986B0273
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 18:35:35 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id q26so52608644ioi.10
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:35:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=U4pzQFaTqh2XOiOYIYGrd3PrDvCK4mJFksSJBVKvamw=;
        b=rqsC5mEBFqQ/WmHvbNJJK90s2rOT1l2t/ZY3Ejz/0KN1i11xdCzXfBQK+vmWFYLWUY
         qXndxK51BEGSSJxJ5YrVhw7HDS4539Y6PSZz+CnVig2kT2daAa7D4DXPOs/F/PENHMTQ
         9EtU6HjYa+6COLY9kSaQ2p3ad9EUC3fTSw3YAgqfNp7cy/cn59hhNuMlTsfkie2Pgpw3
         priacZWbFAXXk/HTxC/ALRxoQJ8RbX7lLCmI0yZk4uSZxIVDroF4MSZLqys6Ze6YWdKi
         ZCykJo7KZOrf/b+M5o6uLBMj8M6TlSTxwkA2/9rcoLnZu+/lhR+fYfbtkWiC+RvW0ls8
         W5vw==
X-Gm-Message-State: APjAAAUf85gZg2HZ/p7gbZJvn2cr1NnZJbXxN8lH0wcWpWjM1VaoWJD+
	m3Q3KPAwZMAA5sfOt+caQ1WexMJnfdulQguTjPCwLPRkwVCNicNP7n+nPV9TgYR6lU6iBmMnA91
	6QSHR1GNnbtpXQwOtKqgJ1F9dEcecDPBKs2sRhSzVxfltAC75ivPcRpwc8KzRDtXx/A==
X-Received: by 2002:a02:ac03:: with SMTP id a3mr90399162jao.132.1564007735083;
        Wed, 24 Jul 2019 15:35:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzc1MxE4ss3f0txYB7nas2HV55zoRL1EnshKYnZ/VyysQTAGf0duWchHAGF97K7hvraXzNq
X-Received: by 2002:a02:ac03:: with SMTP id a3mr90399120jao.132.1564007734560;
        Wed, 24 Jul 2019 15:35:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564007734; cv=none;
        d=google.com; s=arc-20160816;
        b=OKQinNPNTBaNRrrZ/Nd355EvPDxYbrVGfR4x5mw3+TaYdlCPmLvHg53OGS1k6terxO
         YrPXA//rGU3Cp7maAohThLlOpebl/hWh7zgeadgli3eBPRxP1/qHihkBR169FHiVPMmF
         Y90ViZ0z00Mboos/b//Hlv8zvgy2M105f1xhVefpbI3IgRO/VnxmH4SgNrAgd4/BCuky
         HfA2gsbi6Y+iJGWGirLPdj2GRpRSV3P2rcVeD/ij3vCOh44fYmY+QD7kgvO1vRa/9zHA
         YE7kVE0DBKfZ9o/Pf8H56/5FP5cdKFc74paPGWRW3UWSODc7RRxAsGHljQBK8rm6YH3I
         Kc3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=U4pzQFaTqh2XOiOYIYGrd3PrDvCK4mJFksSJBVKvamw=;
        b=PkqoQtYv5tD1/7GHlRFIelj9lsxs+LmONzJeX/fxPru+ZDWjwjS0IfIzn3Aos94q6L
         PJijRBpdQBvQ16lu4pfrevdcroDORl8pgXqSLkh8Oqg2SkvEUNaw/mjSvM71iCwcrebx
         3Y1L3BCJSzwzfzitvcwIVFZqIdje2yD34ivphKSvg79N+NvhTqil+Hn5maYeR2JGGfZS
         Xv0A7iX8OnFaFNgvab/dsl1ZT58hXT1PkgkMTBBmY0327bsR3xhP4EPqf/+dPFKWGnoU
         3nQ9235Kvw1tL4juWLQZbYWYe3Dhv3L6+ALfkYX2ptRWUdXnn4Ly7tA/H8tc6UdZSk1k
         kNRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=WTZ94cyv;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id p24si61485203ioj.51.2019.07.24.15.35.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 15:35:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=WTZ94cyv;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6OMYI7E084566;
	Wed, 24 Jul 2019 22:35:32 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id; s=corp-2018-07-02;
 bh=U4pzQFaTqh2XOiOYIYGrd3PrDvCK4mJFksSJBVKvamw=;
 b=WTZ94cyvp4Do8h7aI/r4Z6H0GG4Zcjo4vAtSB87T8dK+bqO6W/fKEpuj/u5ommISwJ1U
 fuSm36//fsHiz9nq+tkqyEH2TwG2Kg9EFVNGRP0shWxi351X5tEBj5kS5PJw6bZSUZuv
 ISJdZYofxTEHCIHI5P+dbJ++ml5IFl69iT78CHWmiFkVzArBgfZZcnF9HL3aRGw+qeeP
 6BJOcfxLh/rSSWVxI/gkmX8MtaDcpBMQwTrlsCWTF2e1O4d4iMKUmGoBDjsJWbIXI3x/
 O+xsSNmjxAbhajB+0U7Uk9GrNcS2oeLacrddtpzhBTUNTiJBfYIVrrYAO072HU+zMhmE Tw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2tx61c05p9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Jul 2019 22:35:32 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6OMWKtg152604;
	Wed, 24 Jul 2019 22:33:31 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2tx60xfskp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Jul 2019 22:33:31 +0000
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x6OMXTEj029517;
	Wed, 24 Jul 2019 22:33:30 GMT
Received: from brm-x32-03.us.oracle.com (/10.80.150.35)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 24 Jul 2019 15:33:29 -0700
From: Jane Chu <jane.chu@oracle.com>
To: n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: linux-nvdimm@lists.01.org
Subject: [PATCH v2 0/1] mm/memory-failure: Poison read receives SIGKILL instead of SIGBUS issue 
Date: Wed, 24 Jul 2019 16:33:22 -0600
Message-Id: <1564007603-9655-1-git-send-email-jane.chu@oracle.com>
X-Mailer: git-send-email 1.8.3.1
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9328 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907240241
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9328 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907240241
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes in v2:
 - move 'tk' allocations internal to add_to_kill(), suggested by Dan;
 - ran checkpatch.pl check, pointed out by Matthew;
 - Noaya pointed out that v1 would have missed the SIGKILL
   if "tk->addr == -EFAULT", since the code returns early.
   Incorporated Noaya's suggestion, also, skip VMAs where
   "tk->size_shift == 0" for zone device page, and deliver SIGBUS
   when "tk->size_shift != 0" so the payload is helpful;
 - added Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>


Jane Chu (1):
  mm/memory-failure: Poison read receives SIGKILL instead of SIGBUS if
    mmaped more than once

 mm/memory-failure.c | 62 ++++++++++++++++++++++-------------------------------
 1 file changed, 26 insertions(+), 36 deletions(-)

-- 
1.8.3.1

