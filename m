Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09D7EC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 23:47:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF8992173C
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 23:47:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="RunNMqM5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF8992173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E313C6B0006; Thu, 28 Mar 2019 19:47:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE1776B0008; Thu, 28 Mar 2019 19:47:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1DCA6B0006; Thu, 28 Mar 2019 19:47:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6A52E6B0007
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 19:47:25 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id u8so170641pfm.6
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 16:47:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=YKhHIoTYyJM/435yIx1s2AWNgwh6kvVxpU1hFFuHow4=;
        b=MwXlYK/5g8l/OSywVydGkPxDlz9cFjUDCusFKcpJRL67KA37q1piEjnJ0rKxTkzOdj
         n/vslNT5H15/1jxZhjoeYPCYEd3mw3WqBM93W/ZK2fj1NeZyt1jEOEUT/bNYoHkAaah5
         vbzjZbBXsSMoV6n+6FEqwLmzaGwaj2o21nj4bRHNpXJkFxGfOowJuvR31UkdMAVrkdrw
         oTRu/VlYFbW0RWc0PLq9TBVfixOswYZD2S6FiSjWX7u2rCjDTH40pB+BW1wYtBx8HERF
         nmecFFQd9r+mFbknzFFKOipejh9XxYtyplPyMy5uAX9cKdhWGnsp1PhNotzR+/BFRHdX
         +G6A==
X-Gm-Message-State: APjAAAVBBAvP4hZgHs+BNrX5QmT1aHWMjUoE196Kn5MAUKkrFukuNhqg
	o1mJApiLJUPD+N+Ae2ftUyqVkXOrx/6h/PVoN/44Wh4E9XdsEUTmYYpAF3GUU4VIEI09mNPhz8D
	jgWrB1MpXx3pSVbfnAGuRYiTDr8vkDBY9IseYqP8tISjE/trd5oJjL1cH8xvHMG4KDA==
X-Received: by 2002:a62:449b:: with SMTP id m27mr44379907pfi.79.1553816845052;
        Thu, 28 Mar 2019 16:47:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy2Z8f2998I/BDJvRQcYpKxIQj7+dNXkQdLLAMZSSBvV6lJXpG0NEQ2hrijUDCw1dDtxs6d
X-Received: by 2002:a62:449b:: with SMTP id m27mr44379868pfi.79.1553816844259;
        Thu, 28 Mar 2019 16:47:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553816844; cv=none;
        d=google.com; s=arc-20160816;
        b=slcpX87HWaNHNPgn7ouB4Otj7Fyue+y49OslxM6DSKqY1fWV15EPh5uBxcl8J7XBSL
         1LLw6zd2s15jkAb9n2fcz9Y+iR6/TfXeQwiXyZHaug0KKKMN+m1Dlra1pqZ3SYMXSPvt
         qE8f8t1flFJYGglmbGV/vkhwINn61C2fW+0psJOKmDJ+UTu/rGCW8E9ne/kldh9O4NIz
         BJXbnFIj39ABm/WXIv3M80S4R5Z9kSk2xFzd2UMU/XUpSEINHXePReHooWofcN9GcUx6
         1Lpe1FXCHlnr5n/mTViQ4LxKbOzJXSnxsnpcjyqw4gLkMBEv2j8oe0LKm5KM23g21RP8
         4i+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=YKhHIoTYyJM/435yIx1s2AWNgwh6kvVxpU1hFFuHow4=;
        b=TsgxXNqeJzb3ikMt+T5hEfbpYbCY94rZYqQI7usRcMytG6/PImm8NyB9qvTbisa1Qi
         ZHkmU7wAvmOlTbiXBx2KCdBZH/r0uQ1kgvwctfAIGOXTVBmyK32Au3Xa8e7p58IT4GUq
         ATl8hVcQ+Aqo2wPT2XYSSb7MnJWKA0ENrOMt9nF2Q2SXb/ww12Y4cMw1oX58AwZKSxpL
         lXCoc6C3bBZo3bZpVRIZOYY1YlLVox5bFCO8PlV7jycgrJLf+L3IvA9mTDa/9rUSSkTB
         5HfIkmUBwR7rvD2eNLkn30Fdcy9oJBMCA0075bNTP8iDAmardVdfX7PGjA8xfCh958lx
         aOeg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=RunNMqM5;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id q17si444804pgq.392.2019.03.28.16.47.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 16:47:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=RunNMqM5;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2SNiccZ133406;
	Thu, 28 Mar 2019 23:47:20 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : mime-version : content-transfer-encoding;
 s=corp-2018-07-02; bh=YKhHIoTYyJM/435yIx1s2AWNgwh6kvVxpU1hFFuHow4=;
 b=RunNMqM53f2PTc1aTaL863HSzFU5Y20yO6WA/b5ENbcYKGy6uL/Mk11FCpzOzmQbBkRz
 UHsoR0QGvMuLX1VdKwBoGleRvWf9U2++d0SDNEn6HXQsPBMVaI5sZeowoST/a0P38ZwT
 nhE0iL9guZ0GLI+6UztwknnSg4NAou4PcEDTOCTi9KF7NCOaoUDLTjl1wsB2A+g9EIDU
 SWi2yPpYdU+SjWeB01HY8PY/9jsboYWxeHQgOS9JNGaeJlLnN44kLR0b9wzWLaByA8B7
 LgvWo48KbhGmEMTUNPBocd2uxXB+1NqgXEmAVHXFzFpvLSP17iotEADPRLJ9i2+WA+yd jg== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2re6djsmec-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Mar 2019 23:47:20 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x2SNlIZL015595
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Mar 2019 23:47:18 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x2SNlEpm015975;
	Thu, 28 Mar 2019 23:47:15 GMT
Received: from monkey.oracle.com (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 28 Mar 2019 16:47:14 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        Davidlohr Bueso <dave@stgolabs.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2 0/2] A couple hugetlbfs fixes
Date: Thu, 28 Mar 2019 16:47:02 -0700
Message-Id: <20190328234704.27083-1-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9209 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=747 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903280154
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

v2 - Update definition and all callers of hugetlb_fault_mutex_hash as
     the arguments mm and vma are no longer used or necessary.

Mike Kravetz (2):
  huegtlbfs: on restore reserve error path retain subpool reservation
  hugetlb: use same fault hash key for shared and private mappings

 fs/hugetlbfs/inode.c    |  7 ++-----
 include/linux/hugetlb.h |  4 +---
 mm/hugetlb.c            | 43 +++++++++++++++++++++--------------------
 mm/userfaultfd.c        |  3 +--
 4 files changed, 26 insertions(+), 31 deletions(-)

-- 
2.20.1

