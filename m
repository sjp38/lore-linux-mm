Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 623FEC282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 22:17:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1095220869
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 22:17:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="h3XATDKP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1095220869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0EF328E0007; Fri,  1 Feb 2019 17:17:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A0F08E0001; Fri,  1 Feb 2019 17:17:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0E7F8E0007; Fri,  1 Feb 2019 17:17:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC75F8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 17:17:31 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id e1so4597849ybn.7
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 14:17:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=jMv98NtOYPEft23Hv++rFkEKda7ewqGplVbaahr6EuI=;
        b=rjVJ7OP7Ca2UNIBbsMf5eM5p3Nfn6X54sQGLqRJSTmZbS+ikBYQSvQ3De1kqaMBX6k
         4yeFEY6IuxpWquUZYpi4ah1hfAB9kdYNDQ+DixXArRTTQPSs8U3Q7Izsnx2hCYKfY6en
         bzT8/PYNtpnn2hvDErr9GgxSiC0Otgsqhm9nGjGZYGpp1iNygVeAGIB2oREnFt2yv5vw
         lphU/JLC+pVXRAbFaXdPhBGFPdo70XHfTo/A6BkTGlcXFBAAJOFUTzHA8ofWDysu7oAP
         fgZdK+v/YC9fLBQlzYcnVQG9PYp/t/THV9ZVtw6jzXcKsDd/rg2oKGHpsrjxAtxY1rpz
         DAuw==
X-Gm-Message-State: AHQUAuaL3+65mSIFcSlyMAc7Twm8SJu+FZ6dA/BWLJe+39JoHqUR+OKG
	I2mukNmBk2FJU1uKIRpV5/f/xyuTRUqgyQ4KrlIlATt06T3dGN/oQbrJuoPkheAgpGf47E90Umm
	4a4CPhDq/UERCvoapVFhnlHIwRZKyXkQ+z2Xx5oT9vJXpFr550/cPtQ5gotCuAqg96Q==
X-Received: by 2002:a25:2402:: with SMTP id k2mr7781208ybk.515.1549059451455;
        Fri, 01 Feb 2019 14:17:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYaf8GF6xyKjgPFXwLeudYfpY3IUcEa1NI6P328pLcVwOjPRm3z5ZtFAjL7qnRQUg461mn5
X-Received: by 2002:a25:2402:: with SMTP id k2mr7781176ybk.515.1549059450631;
        Fri, 01 Feb 2019 14:17:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549059450; cv=none;
        d=google.com; s=arc-20160816;
        b=S1VHXn0AfZFcEtlEcWuPS4EzkHcs/oNVuLtywwLb8KmXkGsiVq/fsqWPfOPzwH7/yE
         333OpX4sL1mm6YESN+8SCwRV06aeiD4JtI+DOadW+NUd3gSPjqPfnUyFTBgui0XtvEYM
         eVUzASAg1YcDOlW1hJ/vDK4nY2vNXiopl8zTfdIJjc4QjBPReLu05yGejbDLajXpw58x
         1y8L4rMJYpc1Lex3POEGZoMrfWj2Y8K3SWKRooP02GqV52uGWvCPvWbcZqUi1wcm/5Jf
         fV0xlvunfc84tcseSv0+eYop1oEGH8sgkl3Gt1oWCEntUkA+oavOTcP7ZuL7CZWOa7Vr
         5ZnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=jMv98NtOYPEft23Hv++rFkEKda7ewqGplVbaahr6EuI=;
        b=RaBbuzOCZp68Ra2vtY2PVO69tAS06oPquX7C1HcUbcLgS8wtDnAMX7ltl4Il8tXlmx
         bhAZBIRqUwCrKvHYgWvMkOjPRBn9u9UAIiYoffstNtYJz9XT8IKbf3DUgiZ0zuW7Ng26
         NYa0C7KR4lxD592bpixNUdwyC0wvasj/S1467kZ4My+/MTGz4+HXFk17LgMCI4XB1Dx/
         BcKTuC9lStUAnPhq1xW/b6+H1R7zJVUK5b9pKNQtHrIksJJDVpS4hBJsSG/xRLqdxhcb
         o9Wy5xP7R8RHuXEuAzWT5p0xs6UbvyKa3jxnv3NHJW0t4YUJBiPKXeA2qQAJ08oSFixC
         xhSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=h3XATDKP;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id k3si5251894ywe.195.2019.02.01.14.17.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 14:17:30 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=h3XATDKP;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x11MDrUN177372;
	Fri, 1 Feb 2019 22:17:23 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id; s=corp-2018-07-02;
 bh=jMv98NtOYPEft23Hv++rFkEKda7ewqGplVbaahr6EuI=;
 b=h3XATDKPLT1tkgZrH/AJaY55sw856YfCWPYaTA+yX+RjN/RIA2NlVYXc11pRiU5JGMv6
 3BYHGEGYTsTm3YPmalZxmUnmNdegWAZVP41gTWU0sHZDZGTVKWC9j6ElSArGYyaAUIjL
 yS8ABXQayzPbzQ+MDnSVvf2DgKHGs3BPt0MURPbyQkf0qzMO5lFIZhPjIe/ZrHbQdU30
 to0EDTnPwZE7qAhF6tM9VuPOvD2JAYTch2TIOZhN7elwXEEPutv89vvxaZGgIipKFOcm
 Rlpb/RmeLZjt0QyC1Fq4nGkm4jn6W7afMWSOCba2PtVlUiame6iVLaliPFHEzJekJIRL tA== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2130.oracle.com with ESMTP id 2q8eyv140y-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 01 Feb 2019 22:17:23 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x11MHHUa013811
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 1 Feb 2019 22:17:17 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x11MHG7F017221;
	Fri, 1 Feb 2019 22:17:16 GMT
Received: from monkey.oracle.com (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 01 Feb 2019 14:17:15 -0800
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
        Andrea Arcangeli <aarcange@redhat.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Davidlohr Bueso <dave@stgolabs.net>,
        Prakash Sangappa <prakash.sangappa@oracle.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH RFC v3 0/2] hugetlbfs: use i_mmap_rwsem for more synchronization
Date: Fri,  1 Feb 2019 14:17:03 -0800
Message-Id: <20190201221705.15622-1-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.17.2
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9154 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=504 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902010157
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I'm kicking this back to RFC status as there may be a couple other
options we want to explore.  This expanded use of i_mmap_rwsem in
hugetlbfs was recently pushed upstream and reverted due to locking
issues.
http://lkml.kernel.org/r/20181218223557.5202-3-mike.kravetz@oracle.com
http://lkml.kernel.org/r/20181222223013.22193-3-mike.kravetz@oracle.com

The biggest problem with those patches was lock ordering.  Recall, the
two issues we are trying to address:

1) For shared pmds, huge PTE pointers returned by huge_pte_alloc can become
   invalid via a call to huge_pmd_unshare by another thread.
2) hugetlbfs page faults can race with truncation causing invalid global
   reserve counts and state.

To effectively use i_mmap_rwsem to address these issues it needs to
be held (in read mode) during page fault processing.  However, during
fault processing we need to lock the page we will be adding.  Lock
ordering requires we take page lock before i_mmap_rwsem.  Waiting until
after taking the page lock is too late in the fault process for the
synchronization we want to do.

To address this lock ordering issue, the following patches change the
lock ordering for hugetlb pages.  This is not difficult as hugetlbfs
processing is done separate from core mm in many places.  However, I
don't really like this idea.  Much ugliness is contained in the new
routine hugetlb_page_mapping_lock_write() of patch 1.

If this approach of extending the usage of i_mmap_rwsem is not acceptable,
there are two other options I can think of.
- Add a new rw-semaphore that lives in the hugetlbfs specific inode
  extension.  The good thing is that this semaphore would be hugetlbfs
  specific and not directly exposed to the rest of the mm code.  Therefore,
  interaction with other locking schemes is minimized.
- Don't really add any new synchronization, but notice and catch all the
  races.  After catching the race, cleanup, backout, retry ... etc, as
  needed.  This can get really ugly, especially for huge page reservations.
  At one time, I started writing some of the reservation backout code for
  page faults and it got so ugly and complicated I went down the path of
  adding synchronization to avoid the races.

Suggestions on how to proceed would be appreciated.  If you think the
following patches are not too ugly, comments on those would also be
welcome.

Mike Kravetz (2):
  hugetlbfs: use i_mmap_rwsem for more pmd sharing synchronization
  hugetlbfs: Use i_mmap_rwsem to fix page fault/truncate race

 fs/hugetlbfs/inode.c    |  34 +++++---
 include/linux/fs.h      |   5 ++
 include/linux/hugetlb.h |   8 ++
 mm/hugetlb.c            | 186 ++++++++++++++++++++++++++++++++++------
 mm/memory-failure.c     |  29 ++++++-
 mm/migrate.c            |  24 +++++-
 mm/rmap.c               |  17 +++-
 mm/userfaultfd.c        |  11 ++-
 8 files changed, 270 insertions(+), 44 deletions(-)

-- 
2.17.2

