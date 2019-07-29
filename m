Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B1A3C7618E
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 21:10:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8BA020693
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 21:10:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="AVm6GvBC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8BA020693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79F9E8E0005; Mon, 29 Jul 2019 17:10:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FF938E0002; Mon, 29 Jul 2019 17:10:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A0D58E0005; Mon, 29 Jul 2019 17:10:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 354448E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 17:10:20 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id h198so53122501qke.1
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 14:10:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=4KSes26WgUMhT1igPrIU0w8ZoUI0wOL00tWHmqFWcug=;
        b=bmeKh+YshCLnAm9AD47aTcMtQtfIHTXTPLxWHIcbAhlPbw0+iSQiXctqTPWSLt/uZv
         POMZZnzzdseaVB/vCQr9N2v+s3/a2DutjXIy9rA1j/SEkz89vwxquz4bwClPeKqz4890
         QS++plxc3RA9UZLcrfby29cYcS4y+ElFxafi6Xml4zBl+1XMWpIsT9js5WDpBrYydtDr
         DqjGmr34DSe6k/capMLBBQzp9/9aQptoRZATAKIKhRoBzONKHLGGLtfjSplSy6edQZd5
         EzAiHez105Tik6m36OemfXkOdUnzMR6xTgMTGUfzoiTWrvtq73ohKA94x7w9bPJNjMLk
         UcnQ==
X-Gm-Message-State: APjAAAV3C/FGi3AKRwnhxuAY9h0h8W1UM1b+6bOpZZGO0ZwrJOF1qOj4
	9zm653qNqEbh9MreL6R6MD0eNQ80MBNcc7xeFHaJX71wOwmDvvSsx5RJXrlmECcC2gNz5xaEx7Z
	qbA/6PWLVBM8AD14mjhUYIcw9gZLF8nSORJQVvgIV6Rd4UZS/A7890oRT7CkWjfpW/w==
X-Received: by 2002:a0c:d91b:: with SMTP id p27mr79506689qvj.236.1564434619854;
        Mon, 29 Jul 2019 14:10:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSUY8utw8i9v+fzH3rRZ57OiI0JhEjRxk0uRkubgpZUslU5qklPHZ7v1+kUEaAMEX1l0VG
X-Received: by 2002:a0c:d91b:: with SMTP id p27mr79506660qvj.236.1564434619131;
        Mon, 29 Jul 2019 14:10:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564434619; cv=none;
        d=google.com; s=arc-20160816;
        b=efklpMHa17+vAKwlN7fyJG/6vk3OlW7R3x2C3KkOVWHKbRr/DTwgj7T3dvBUe5vViW
         cP6ylnrBnhL06KZTZGVfzD+xgAqNJsUlDNH1ITUPDmTv7MMO2BfeQFXP7B7TAlDiOYek
         50kYFMXfxSw+xTKT6lRjSkUdM/mR2hxxjvrGm1d8dldJXvb9XqTUj2+G5GU5W/6n9hsx
         X/yT+pYu8ywm190jPVYKKE5p+Gvtk1GusdttX7nlOy7dRGIU+iYCp6QdgzvDF7ExD+VL
         jOheT5K2oUBGr0WN/JhSWXO2vw7jYhQURfGRA9dEmPfvXwfUTbH9JywJavPt8QIAOIev
         USrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=4KSes26WgUMhT1igPrIU0w8ZoUI0wOL00tWHmqFWcug=;
        b=raUhl+0romAgReS+DVWnzsNNQFhjj2+c7hqakZpZfA+Waq7Fku1+j5yOJ54LV08Gyk
         4oGEplAOidD5PwpOjRcNq70yA1ldLI1q9MEjTDcz/F8XT/L3IjPNXCWdZpHUIURseAM5
         j27FwZ3RTjw52kiCCtEUO/tAbENjEVf99PjHk4jM1wGs9OQ+SrX/7X5kznscxRgE680D
         uGOjQBECoLou613VZe8VG0KYAF4vuHILYTVl4lMbAbZaQZouL2xm5+i40qii9Xy7gJ8S
         JTKM7z+g0/67qis/Var3ZNgaBY8cb8VkAZDoAQP+F5jJwfYEx32OcMfTRob/gC4ikOwr
         EpsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=AVm6GvBC;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id w123si7967404qka.228.2019.07.29.14.10.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 14:10:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=AVm6GvBC;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6TL9HCm114121;
	Mon, 29 Jul 2019 21:09:56 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : mime-version : content-transfer-encoding;
 s=corp-2018-07-02; bh=4KSes26WgUMhT1igPrIU0w8ZoUI0wOL00tWHmqFWcug=;
 b=AVm6GvBCDSDER9LQ0Vd/Ua8EhdNOfKTyrmbFzUB9hF+j/aquEONk6+lhlpadDjv/Mjxj
 mtjY2EhHRiyMcl6yGg4/hVrDWT1LDkca+vDVENM2NmTtv1xNebX+8MuW5vZ4goaZARSu
 ZQ9KbxJJ2VHNb01YerEPKrJqPIINUdc4InDfktgTOgmaw5P9Wk8qGIu1onRtfQE+br6H
 e+YjUeghWuO4LBKsP6BEtzIwVrYBLGFKRZm/UZpSpQirC26bK4F+E7jLfYiip8h/Oft6
 e2hIv/EjJI1Y9Lsur8xXqlDca75p6LdS5nJERA539BwruA2+ikD7QPCHRGPMt2NbFFrt UQ== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2120.oracle.com with ESMTP id 2u0ejpa4w0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 29 Jul 2019 21:09:55 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6TL7vq9104163;
	Mon, 29 Jul 2019 21:09:55 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2u0xv7rj84-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 29 Jul 2019 21:09:55 +0000
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x6TL9ihD009747;
	Mon, 29 Jul 2019 21:09:44 GMT
Received: from localhost.localdomain (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 29 Jul 2019 21:09:43 +0000
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
Subject: [PATCH v2 0/2] mm,thp: Add filemap_huge_fault() for THP
Date: Mon, 29 Jul 2019 15:09:31 -0600
Message-Id: <20190729210933.18674-1-william.kucharski@oracle.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9333 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907290231
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9333 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907290231
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

Changes since v1:
1. Fix improperly generated patch for v1 PATCH 1/2

Matthew Wilcox (1):
  mm: Allow the page cache to allocate large pages

William Kucharski (2):
  mm: Allow the page cache to allocate large pages
  mm,thp: Add experimental config option RO_EXEC_FILEMAP_HUGE_FAULT_THP

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

