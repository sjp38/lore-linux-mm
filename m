Return-Path: <SRS0=ErOr=VZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2687BC433FF
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 22:49:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C68942075E
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 22:49:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ipTbL/u+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C68942075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 514E58E0002; Sun, 28 Jul 2019 18:49:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4AC858E0006; Sun, 28 Jul 2019 18:49:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 150F28E0002; Sun, 28 Jul 2019 18:49:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id DE78D8E0003
	for <linux-mm@kvack.org>; Sun, 28 Jul 2019 18:49:37 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id t124so50602203qkh.3
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 15:49:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=8mMPVmrqQKrudmz0AKLMo69+kwtVzvBZ2lRB0+ICDsY=;
        b=eVLKmX47pWIqxeECFV9Auklfy3qM++uqO+IN+ONxGPqj2kb0CjrZAamSMFJ7oJGzCn
         kOjWQHRQLpgF/dvh9aiMd0jqSCuOA9iGNkReCxg3bqK3Uvnv5OpIXvmLqWpp495y7NYW
         uGKIVKS4yJdvoMOpDSqhh5Q5DUIuCnD6GA4pB68FqCallitBQBEwCis63+H6Q6+ZWrvA
         xT+mhFrOe1RGy5pDbv/hbxFhFs/yPEzONYPgspzy23Tvv3MEWMOYtKs1LjV1FrOfTIfI
         nO5J5Q9xYGkrjIZXs8IT2hVD2CHANUm2jsKcNNfIatvyKrzNVBi+4K7LEQ6EBxt1Murk
         BBgw==
X-Gm-Message-State: APjAAAUlZqzRtn5nPnulG3ZcCNpPRpds2+HuLuh+hWLXZlvuTcW5/KgC
	qBC5TxRd71DV8BLcG9PFQLV819XiY//sQlvaIYh5AuSL7nWDYMz77FzQ0TI0pfkpCWUocTgZyic
	dQu2ukZjZ5ZKHabAE9jaJwgqw3Z+4fVn0Qpzo58VLzhU3DdhBqRHydPQHBb2lHUTBsw==
X-Received: by 2002:a0c:ae31:: with SMTP id y46mr77560667qvc.172.1564354177582;
        Sun, 28 Jul 2019 15:49:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywmbxoNLIhcHXBQiptU4dS3g3cqaWQlnfFt6rtPsA30KDcHmnLw3zo7Mse3NKDRsBtJpoO
X-Received: by 2002:a0c:ae31:: with SMTP id y46mr77560652qvc.172.1564354177003;
        Sun, 28 Jul 2019 15:49:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564354177; cv=none;
        d=google.com; s=arc-20160816;
        b=hTbU/jienhRtHE3kFm9OUhpLa7c2oSgtOLGrzeb/TFbAARMjlZoUari19cSjCp3cji
         /zxYgBXzazJZFZmWUHMBb8Ivxrbg4jl8jUReiuq5M0Mnhk8Ken01moqr88Dw/ChNZL+M
         fNKstiYSDNHJbYGweahl/aw/xibnarOcXZFX6v0FLWDM9vrEXsIdkyaBokNbEmWdL3el
         1mjMoH0MF05zUDPy2y+Js7YYLBhjAxVfsBut5koKD67YW94gXxgqn6b8rnnFkTJTMM+/
         FGWq4AAIeDeXAfLyCLTyjo8+4QdPLcQF78wrDNr8wnE28Q8oZQGovBfxZZlM8xEixOUv
         uddA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=8mMPVmrqQKrudmz0AKLMo69+kwtVzvBZ2lRB0+ICDsY=;
        b=CGbc/t6K71b0Hkvbze0/tzKKrfZvHi01cAGuJ5LVgHwU47zKvdCsSuwjBzS6fXU6cJ
         a3BX/wU9acxcU+vBkxO+nN39+9wR+7OuNksQ45diZEOMQoxAD3PaP122s4stSCCz/cCk
         PNX5XUvZ0DVjqhrOumDwo+SjblPhPt0Jh71nNtfHpzYlsDCMn2T8werllbeU6qmhXON0
         5IMfWY+A3jeoQ88J+PeJs1DiheWpZ8+MmEroaJsiUhSfJkYJ5p/nCgMjDwtR7OikqwYQ
         qsppcC8kclhEPFbKjzOQwDByoR4GawagVnjjxfP8dBFS8j205McrOIlt0q7uQRWcxz72
         e2kQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="ipTbL/u+";
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id k6si33550887qkj.153.2019.07.28.15.49.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Jul 2019 15:49:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="ipTbL/u+";
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6SMn07q005191;
	Sun, 28 Jul 2019 22:49:00 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : mime-version : content-type :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=8mMPVmrqQKrudmz0AKLMo69+kwtVzvBZ2lRB0+ICDsY=;
 b=ipTbL/u+dhkqRmNwtI2daaR12y1FOMvDLXP6uYQv5SdR4jGxDgVmm4T03XlqsF1pKO05
 q+oHCojyHU4uLwY8wNRZ5PbuQoiegQIbffB8bKRiHg+UVH+rMqv/MCafBMPOuvnZxO14
 le4iEnW1XihN1y3K9uk3kZYQQUXlA4WxpXwXOkMxMTtVRgkmeozQo4wOgdcpBCQUeT73
 XVzBX8xUJo7EDqnCFmbhpEm6Sceb7Q3ksuXCphCZGZKz/Yh/MH4KEUAjRGxr5/CSl9mE
 JcYGApQ9Vin9ZrvniTs0Gt0pBS8U7qfXP4pWmX78P9IF4mPVTkR/XH4xZvY9/AKIzK+K EQ== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2120.oracle.com with ESMTP id 2u0ejp44c8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 28 Jul 2019 22:49:00 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6SMlrIM051001;
	Sun, 28 Jul 2019 22:48:56 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3030.oracle.com with ESMTP id 2u0bqt6t52-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 28 Jul 2019 22:48:56 +0000
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6SMmblC028270;
	Sun, 28 Jul 2019 22:48:37 GMT
Received: from localhost.localdomain (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Sun, 28 Jul 2019 15:48:36 -0700
From: William Kucharski <william.kucharski@oracle.com>
To: ceph-devel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, netdev@vger.kernel.org, Chris Mason <clm@fb.com>,
        "David S. Miller" <davem@davemloft.net>,
        David Sterba <dsterba@suse.com>, Josef Bacik <josef@toxicpanda.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
        Song Liu <songliubraving@fb.com>,
        Bob Kasten <robert.a.kasten@intel.com>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        William Kucharski <william.kucharski@oracle.com>,
        Chad Mynhier <chad.mynhier@oracle.com>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
        Johannes Weiner <jweiner@fb.com>, Matthew Wilcox <willy@infradead.org>,
        Dave Airlie <airlied@redhat.com>, Vlastimil Babka <vbabka@suse.cz>,
        Keith Busch <keith.busch@intel.com>,
        Ralph Campbell <rcampbell@nvidia.com>,
        Steve Capper <steve.capper@arm.com>,
        Dave Chinner <dchinner@redhat.com>,
        Sean Christopherson <sean.j.christopherson@intel.com>,
        Hugh Dickins <hughd@google.com>, Ilya Dryomov <idryomov@gmail.com>,
        Alexander Duyck <alexander.h.duyck@linux.intel.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
        Amir Goldstein <amir73il@gmail.com>, Jason Gunthorpe <jgg@ziepe.ca>,
        Michal Hocko <mhocko@suse.com>, Jann Horn <jannh@google.com>,
        David Howells <dhowells@redhat.com>,
        John Hubbard <jhubbard@nvidia.com>,
        Souptick Joarder <jrdr.linux@gmail.com>,
        "john.hubbard@gmail.com" <john.hubbard@gmail.com>,
        Jan Kara <jack@suse.cz>, Andrey Konovalov <andreyknvl@google.com>,
        Arun KS <arunks@codeaurora.org>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
        Jeff Layton <jlayton@kernel.org>, Yangtao Li <tiny.windzz@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Robin Murphy <robin.murphy@arm.com>,
        Mike Rapoport <rppt@linux.ibm.com>,
        David Rientjes <rientjes@google.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Yafang Shao <laoar.shao@gmail.com>, Huang Shijie <sjhuang@iluvatar.ai>,
        Yang Shi <yang.shi@linux.alibaba.com>,
        Miklos Szeredi <mszeredi@redhat.com>,
        Pavel Tatashin <pasha.tatashin@oracle.com>,
        Kirill Tkhai <ktkhai@virtuozzo.com>, Sage Weil <sage@redhat.com>,
        Ira Weiny <ira.weiny@intel.com>,
        Dan Williams <dan.j.williams@intel.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Gao Xiang <hsiangkao@aol.com>,
        Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
        Ross Zwisler <zwisler@google.com>
Subject: [PATCH 0/2] mm,thp: Add filemap_huge_fault() for THP
Date: Sun, 28 Jul 2019 16:47:06 -0600
Message-Id: <20190728224708.28192-1-william.kucharski@oracle.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9332 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907280284
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9332 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907280285
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This set of patches is the first step towards a mechanism for automatically
mapping read-only text areas of appropriate size and alignment to THPs whenever
possible.

For now, the central routine, filemap_huge_fault(), amd various support
routines are only included if the experimental kernel configuration option

	RO_EXEC_FILEMAP_HUGE_FAULT_THP

is enabled.

This is because filemap_huge_fault() is dependent upon the
address_space_operations vector readpage() pointing to a routine that
will read and fill an entire large page at a time without poulluting the
page cache with PAGESIZE entries for the large page being mapped or
performing readahead that would pollute the page cache entries for
succeeding large pages. Unfortunately, there is no good way to determine
how many bytes were read by readpage(). At present, if filemap_huge_fault()
were to call a conventional readpage() routine, it would only fill the first
PAGESIZE bytes of the large page, which is definitely NOT the desired behavior.

However, by making the code available now it is hoped that filesystem
maintainers who have pledged to provide such a mechanism will do so more
rapidly.

The first part of the patch adds an order field to __page_cache_alloc(),
allowing callers to directly request page cache pages of various sizes.
This code was provided by Matthew Wilcox.

The second part of the patch implements the filemap_huge_fault() mechanism as
described above.

Matthew Wilcox (1):
  mm: Allow the page cache to allocate large pages

William Kucharski (2):
  mm: Allow the page cache to allocate large pages
  mm,thp: Add config experimental option RO_EXEC_FILEMAP_HUGE_FAULT_THP

 fs/afs/dir.c            |   2 +-
 fs/btrfs/compression.c  |   2 +-
 fs/cachefiles/rdwr.c    |   4 +-
 fs/ceph/addr.c          |   2 +-
 fs/ceph/file.c          |   2 +-
 include/linux/huge_mm.h |  16 +-
 include/linux/mm.h      |   6 +
 include/linux/pagemap.h |  13 +-
 mm/Kconfig              |  15 ++
 mm/filemap.c            | 322 ++++++++++++++++++++++++++++++++++++++--
 mm/huge_memory.c        |   3 +
 mm/mmap.c               |  36 ++++-
 mm/readahead.c          |   2 +-
 mm/rmap.c               |   8 +
 net/ceph/pagelist.c     |   4 +-
 net/ceph/pagevec.c      |   2 +-
 16 files changed, 404 insertions(+), 35 deletions(-)

-- 
2.21.0

