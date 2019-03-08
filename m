Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B828C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 22:48:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A8982081B
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 22:48:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="4hqj/AhG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A8982081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D1D8C8E0004; Fri,  8 Mar 2019 17:48:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCCEB8E0002; Fri,  8 Mar 2019 17:48:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBB038E0004; Fri,  8 Mar 2019 17:48:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7716C8E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 17:48:43 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id f10so21816751pgp.13
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 14:48:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=9mYA2OMneODE0ER7VYzeYVrHjR6dxQoAsu+AqTsDnc8=;
        b=Ov7E7JFeHk51qH9tz1tcZaww54JTI2yjNZjwOgY/MEDXpKr7A5ontYWdraAmccWKDZ
         gRyxgkeZw4vR+yfasnOLSGdP55gtdkx40xrnJFwph/EAn4E3s4iAp8GEikeSKvghhTmw
         XCuOaQ5F16vkenxBjWhTRjnmT4sos237ZTh3DnxhFLpQkyVKk4NOYJLUaCDEbeyE86rW
         sSjsRSjiZOvk51edD2schbJsEfsfcG8jTWqRyZKtumTxtJGD4oiJX6LLb/f2uKsZMX2e
         QcoSghX0n5uQCP9o/CF5Qe8/5+S60qORMh3OSUq2WOocbptbaFL4R97W7DE/qmuJepeF
         bclw==
X-Gm-Message-State: APjAAAXFNxcyg5VcwEknhZ6jZQh8EHTBZkBfq25mrXEGRdQWLnwU9idd
	J1RaArLptx9hx4QvbIhoa6MKuLNcVmbO++cvI5FBbu8gt02I13WKdxrfPaBmnvPPfDTFlkqgbd4
	QdsYjhmFtybnu4sFebaJCfbAYZlNFcu9a9tp2DFSEGQ9yF+xJc+xjUxn9PyY0Zo93UA==
X-Received: by 2002:a65:6489:: with SMTP id e9mr18879889pgv.260.1552085322931;
        Fri, 08 Mar 2019 14:48:42 -0800 (PST)
X-Google-Smtp-Source: APXvYqxb98ZHwVgwfoEC84yJ+ZHcQvt4bFefpFqA2cyQNr/xm9nDZNe9rttloahXoUZ+OptyQbAF
X-Received: by 2002:a65:6489:: with SMTP id e9mr18879864pgv.260.1552085322144;
        Fri, 08 Mar 2019 14:48:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552085322; cv=none;
        d=google.com; s=arc-20160816;
        b=wpn4UXvs86LQjYQtZx4bmCfYIMmCJwXSzdV9vXdldPqRflyQVoqgj9CQfrd2UhM/Pv
         a5nqs2Pav3gT3gWfgAkt9OapmqU6BgD7RineFBpZ2htgHvRpL3d4cTy0TaV2XrLRMsxt
         uw/tqgB9T9txduvfwYQrHZ3zC4n2b+MuGVOhoscW85jRZ0UiPTImtrDmNbvbC2bIBley
         f29fWxk8/9Vw5+WEa6TsUknZ2jrOroIpSVOinaC4G59ftf3hjbPuHYvPFpWfhIy68BGc
         EjxNSvWz33rxBEq3B0mO2jV5FPxbO3+pbt26rpcFAaVZ1yixKac1GcZUfFI79H8PjEb+
         o4MA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=9mYA2OMneODE0ER7VYzeYVrHjR6dxQoAsu+AqTsDnc8=;
        b=qk56FlqKJ959J/zxZ/hRjQAWflQn5QA2BeCEKNB4lleRE1SIBfWCdpOjUOejmVqsnj
         RopSQ6v8ZMhd1uYr95r3JwVUXDcgXmYO9PoKL96VnVjwy285kt16EFPc0FnNpA7o785n
         cmU0FuLyFQAvtil7PDOGUq19RuOIA4Y2yyNek7l7Rfjsc5SaqPj/lpt+jDgeDOARsAHr
         SqWhdez81LLeuzYN2ql/yiD1SG8iJf8RjjLbIJhWKDkaA5XYvLt24IlHMkwpIgkvbW2+
         y0xk4yhhTLUCqwPdjrk6hVKe6BBUvODdJEOIOL/MMjLR71N5YIIhfWjo1obh9KlzkENY
         Cquw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="4hqj/AhG";
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id o17si7819804pll.344.2019.03.08.14.48.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 14:48:42 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="4hqj/AhG";
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x28Mhavn022229;
	Fri, 8 Mar 2019 22:48:38 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id; s=corp-2018-07-02;
 bh=9mYA2OMneODE0ER7VYzeYVrHjR6dxQoAsu+AqTsDnc8=;
 b=4hqj/AhGnV7ErTjU7Vl/dWj1f83Eva1SRhfJSrsQXnXdtLU5dsuTquyZt+FecsPnq5VW
 Hcd3Iyq4DwcAygyYz8bdRTAeMuMjU28IOy2Pxztrzz1zi/A9dRjkbBl4Lt1S1cM1IoZU
 +KyYDyugmzE7/SncsZziA539fCq9MnGOaaxQoLjRnv7Y2hwPy3ZmRg3ySIGRG3tUdJN0
 2Li/Ig+lV/zrQRNaedwMUNTClBOnLdsVjKhHCWswZAJmaajX5Jet0gj0L0BjFop8a6Km
 rIPtwV4QoUkQR3RAfaJccztZgEl25O5CWyX1F9nb/aS+YUgOD89xB6r6TAOzfTD6H01R bA== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2qyjfs2r3f-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 08 Mar 2019 22:48:38 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x28MmaAC009035
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 8 Mar 2019 22:48:37 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x28MmYCc000689;
	Fri, 8 Mar 2019 22:48:35 GMT
Received: from monkey.oracle.com (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 08 Mar 2019 14:48:34 -0800
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Davidlohr Bueso <dave@stgolabs.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 0/2] A couple hugetlbfs fixes
Date: Fri,  8 Mar 2019 14:48:21 -0800
Message-Id: <20190308224823.15051-1-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.17.2
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9189 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=684 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903080157
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I stumbled on these two hugetlbfs issues while looking at other things:
- The 'restore reserve' functionality at page free time should not
  be adjusting subpool counts.
- A BUG can be triggered (not easily) due to temporarily mapping a
  page before doing a COW.

Both are described in detail in the commit message of the patches.
I would appreciate comments from Davidlohr Bueso as one patch is
directly related to code he added in commit 8382d914ebf7.

I did not cc stable as the first problem has been around since reserves
were added to hugetlbfs and nobody has noticed.  The second is very hard
to hit/reproduce.

Mike Kravetz (2):
  huegtlbfs: on restore reserve error path retain subpool reservation
  hugetlb: use same fault hash key for shared and private mappings

 mm/hugetlb.c | 30 ++++++++++++++++++------------
 1 file changed, 18 insertions(+), 12 deletions(-)

-- 
2.17.2

