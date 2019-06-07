Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1EE3FC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:52:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6351208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:52:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="O4Q4lH3b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6351208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A0AB6B026A; Fri,  7 Jun 2019 15:52:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F9A26B0269; Fri,  7 Jun 2019 15:52:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C0956B026C; Fri,  7 Jun 2019 15:52:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E552A6B0269
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 15:52:45 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z10so2086311pgf.15
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 12:52:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=2Hqgg1/dO7uDJAgCGo7yaezXbdAI6xjToJ1CY+fruaU=;
        b=lQ2LOSq31MAMUtKNA1P2C/0DVDXGGiAJTp1uzPPd5ZFAMWwOycEG/dhsCmIIcU0FF4
         nyNoD4qiNTubBP2nlKOzwGFKm2KRbRRo4bo41tmP9dLjuDO5VYOHO1GJ2ENGiVFDroxa
         wvdRgl0u6Wgc9Qyv8E0oi+rnH0bMh6IQE3/pPRnnVHiq80orF9OJmCgP7wHDBZ1x1CUE
         RC0mAQcuz4B+xohsvnBblJEQKMGpUkpEwQYWKmOVaWNS9cQlzCsiIEjhFLPS2Y8/yS3B
         7591ilijEq7vH9//kmDmbsv5UKDAm5c10HM4QgM0pzAClrKgx9CpMPkTumvoUhAmSCBR
         Y6Lw==
X-Gm-Message-State: APjAAAWA4J/BF+KHdn/xC7c+2mZgy6fnoOpVQEp6mp7grdARJgOduuaP
	ncuW/cpjiHeJx1kIiiXFuVKhBrb38Ah95LLq7tYI4ryxe4bxX9Pkh45SLiONxNd+Q4BzPApdYnB
	hl7kVhWepXhv5Cj/l8cN//x8tQdC6KvSwjwb4kW/cVnUTppCEN5kw0aSvqsqMyWqxIg==
X-Received: by 2002:a17:902:bc47:: with SMTP id t7mr45399397plz.336.1559937165442;
        Fri, 07 Jun 2019 12:52:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2hJciMa+wZjmu+3voOOwpralPP4qsfMUbNL4Xc5+KM7Bs6qUOaOzMSyYg3g01zwVXYIYR
X-Received: by 2002:a17:902:bc47:: with SMTP id t7mr45399359plz.336.1559937164768;
        Fri, 07 Jun 2019 12:52:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559937164; cv=none;
        d=google.com; s=arc-20160816;
        b=h9lYromarJolwyVvQN6Z/0tB0NKjronym7uq6RRa5GZEx3t+nMOPNnvwV6TCsIEkB/
         e5OSjowMv85lQ4+MHzgTmL+jtXpWN6zk4XntautoT4VudTSl4aQQ4K9P6SKLHKm5DMK0
         EWPaPye3S1AzVhq55ffH89eVNAAxNudhD084npzyoanjDj1cw4iK4aCH23u7/lCynKNf
         XcdyuH1xvdNseglL4u/Il1kP99+YVVWLc0cCtnE3euwEI23swBGmDk7M1l6ATUSpuh1J
         qObozqzycqHTFzdXISXZx1l4epkrgbNSjD+wBByJX9G6jx4VOKsPhkH7IivcuXlAXUDn
         ygVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=2Hqgg1/dO7uDJAgCGo7yaezXbdAI6xjToJ1CY+fruaU=;
        b=nf0CpBf0gk89rcBHtWmMV+63PsD6E9sKQffBoce8AyhtW0MyCtLHWHqKIm94MeO8JI
         wxfYOo0KEHxe80TEaSzC5O9l0pT9Wn4qp+g8+PjlTumNSJJqG88zXYq9YNOvauBqutYd
         Sr8gjvnyAM+0TIlhfqi/o1Yy/tc2ottBeDpBfjb0gkR8LCQM23VzpO1BRftxuPIY0OV9
         78BLMVIcQxveuJzsI7PgWd67j1IhnjawmuPjQaK0mdLOpSGR0NUMTUhvcY3ePCNhaj2y
         fL5aOhjvoqYpe0b2mY8uU4IbErDQZ05XqME58TY+b8WXdEItsahGuWvih+qrR44ITl/F
         iEcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=O4Q4lH3b;
       spf=pass (google.com: domain of larry.bassel@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=larry.bassel@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id n12si2778461plp.114.2019.06.07.12.52.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 12:52:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of larry.bassel@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=O4Q4lH3b;
       spf=pass (google.com: domain of larry.bassel@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=larry.bassel@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x57JiKEL098463;
	Fri, 7 Jun 2019 19:52:33 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id; s=corp-2018-07-02;
 bh=2Hqgg1/dO7uDJAgCGo7yaezXbdAI6xjToJ1CY+fruaU=;
 b=O4Q4lH3bRZ7MwIrivSjLjEanSp/1BldkeSoNEhDGZB9H8i68MirSK5kT1G9vfxNC3u4G
 tobWGASbTP9Drb1g9Mp6AfG8qM1rx37y+y4jziC7fhhXc85/r1nyZdjc0AvVPgR6CHSx
 mIG1Ihxno+1jVFyxrLhM0kOMgrsCEXUfm8XfDOuuOU7vnXmbp6UA1fNJI3jhDUe7a+Kj
 2hmnQAljFlUykUzJfFxc07Lcm1cms6sQ9cH5eVDN5A51sxAKeJHRt4ypV3oFix9CV0pf
 SvSI14XmrW8h5CL/zA1fBwxGuMoBQ9DLdBog4cttYZAO5Rx24YoPOe0lSjwY171+j0cH Eg== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2120.oracle.com with ESMTP id 2suj0r05yx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 07 Jun 2019 19:52:33 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x57JpA1j022963;
	Fri, 7 Jun 2019 19:52:33 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3030.oracle.com with ESMTP id 2swngn8kcn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 07 Jun 2019 19:52:32 +0000
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x57JqRQt020424;
	Fri, 7 Jun 2019 19:52:28 GMT
Received: from oracle.com (/75.80.107.76)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 07 Jun 2019 12:52:27 -0700
From: Larry Bassel <larry.bassel@oracle.com>
To: mike.kravetz@oracle.com, willy@infradead.org, dan.j.williams@intel.com,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        linux-nvdimm@lists.01.org
Cc: Larry Bassel <larry.bassel@oracle.com>
Subject: [RFC PATCH v2 0/2] Share PMDs for FS/DAX on x86
Date: Fri,  7 Jun 2019 12:51:01 -0700
Message-Id: <1559937063-8323-1-git-send-email-larry.bassel@oracle.com>
X-Mailer: git-send-email 1.8.3.1
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9281 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=641
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906070132
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9281 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=682 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906070132
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes from v1 to v2:

* Rebased on v5.2-rc3

* An incorrect reference to "page table entries" was fixed (pointed
out by Kirill Shutemov)

* Renamed CONFIG_ARCH_WANT_HUGE_PMD_SHARE
to CONFIG_ARCH_HAS_HUGE_PMD_SHARE instead of introducing
a new config option (suggested by Dan Williams)

* Removed some unnecessary #ifdef stubs (suggested by Matt Wilcox)

* A previously overlooked case involving mprotect() is now handled
properly (pointed out by Mike Kravetz)

---

This patchset implements sharing of page tables pointing
to 2MiB pages (PMDs) for FS/DAX on x86.

Only shared mmapings of files (i.e. neither private mmapings nor
anonymous pages) are eligible for PMD sharing.

Due to the characteristics of DAX, this code is simpler and
less intrusive than the general case would be.

In our use case (high end Oracle database using DAX/XFS/PMEM/2MiB
pages) there would be significant memory savings.

A future system might have 6 TiB of PMEM on it and
there might be 10000 processes each mapping all of this 6 TiB.
Here the savings would be approximately
(6 TiB / 2 MiB) * 8 bytes (page table size) * 10000 = 240 GiB
(and these page tables themselves would probably be in
non-PMEM (ordinary RAM)).

There would also be a reduction in page faults because in
some cases the page fault has already been satisfied and
the page table entry has been filled in (and so the processes
after the first would not take a fault).

The code for detecting whether PMDs can be shared and
the implementation of sharing and unsharing is based
on, but somewhat different than that in mm/hugetlb.c,
though some of the code from this file could be reused and
thus was made non-static.

Larry Bassel (2):
  Rename CONFIG_ARCH_WANT_HUGE_PMD_SHARE to
    CONFIG_ARCH_HAS_HUGE_PMD_SHARE
  Implement sharing/unsharing of PMDs for FS/DAX

 arch/arm64/Kconfig          |   2 +-
 arch/arm64/mm/hugetlbpage.c |   2 +-
 arch/x86/Kconfig            |   2 +-
 include/linux/hugetlb.h     |   4 ++
 mm/huge_memory.c            |  37 +++++++++++++++
 mm/hugetlb.c                |  14 +++---
 mm/memory.c                 | 108 +++++++++++++++++++++++++++++++++++++++++++-
 7 files changed, 158 insertions(+), 11 deletions(-)

-- 
1.8.3.1

