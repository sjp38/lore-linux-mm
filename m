Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAAC8C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:46:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 890882184E
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:46:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="dSPA45Xd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 890882184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6B778E0163; Mon, 11 Feb 2019 17:46:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E1788E0182; Mon, 11 Feb 2019 17:46:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E2F28E017F; Mon, 11 Feb 2019 17:46:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 112EE8E0163
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:46:09 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id r85so1058797itc.1
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:46:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=Phi3yo5tGmVy0t3cuMS6IWQIWpdGP9aDbdf7nHYEaVU=;
        b=NpYuobwBW+LrJioM3XqXKEtTsuA+lEYt2Gtdga4VQrkqHVX4L6f8zTX3+FTnKzsltb
         84sfrvJT0OiN6ABQ6R1TiFRHYi7fXIHGGgMYKe4sd9ypS4Q9j070ajFfXrhX30kpyXXb
         /2m3tbSpHEOsecTpY+joDIRiAk4FvmtmjGyeWfdA4157kY/4gfM8KyYmB3qmMV7vQuWU
         xAcmNpa/Le1LCcHhQHL8Hzu+m6+gKhG9oiR8Ih4jdr7dtZ9oB7MWysUgsPrjFAJKO0fL
         ruTqH/NewaUDsm+wXAGT2wpgKfG+hjIowSwD+IZ4Vka9Y2bRYY/Od73joi/8wQXv79Fa
         4SpQ==
X-Gm-Message-State: AHQUAua+P48AirQtTZkhVKQwaVUSrwlXHNRKbXGNQFXNV6vhvB0zA4xC
	+8UP0/ctXseE0X0Kj7QZH/JShQfGy35MU0CIQcvFp+UdGtm/MoblPKKH/sYtGqiGSb91EdQfwXq
	fLOyxrq49CZoIIcbpCZMGmvyIduhBdB9wcm7RlPrabLKY8J0Ij2xp7rGp6+VznKH/KQ==
X-Received: by 2002:a02:710e:: with SMTP id n14mr104297jac.23.1549925168851;
        Mon, 11 Feb 2019 14:46:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYS5knqsONOHqQ9i1ZbVFip3I4adr8bOojQD50NM3d+xX424zI/lGf0H4oRRahN3ifuilhF
X-Received: by 2002:a02:710e:: with SMTP id n14mr104283jac.23.1549925168248;
        Mon, 11 Feb 2019 14:46:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549925168; cv=none;
        d=google.com; s=arc-20160816;
        b=vsMi4Y1/WKJlFat8ycBcGDuB1oleMrVnJDREj7rhaKsEbGI8O3grxU4W67add+TnX1
         15NbL6EpatpSaXzAD2qF6SF2qu7EVgB5gpFO2ZzASHCfkQkgvGeBm3wTt8dtajlsSzu7
         fca0nDRrzpuBIkwq6DJyIBBPQvsr86QzR4X7oc4ZWAOuDkRkBRmr4gKj8Te9i55w5XGj
         cqplGI8I0pbVUNlfqyZNG9W3YDwFgpa9niyfQdrQbSZG10uF2fzSFYQt4ZpTYgBA+SuA
         PajBq+kR3MM/EPW3cmYIUSWRL7OzTO3wtJQ+zA+DLOBDuO0AQjULoMPJq6jDDvw+yLZ2
         CBxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=Phi3yo5tGmVy0t3cuMS6IWQIWpdGP9aDbdf7nHYEaVU=;
        b=HhgUNTqJJP7UY0D7SZ8vYFjDwpzc/H7H1cBgpRleRww6oih0YvaMvA3mK4XIjm2xR8
         9b4PdWHCOPPjLtUQJ8ohR4fZn6iVvsQTTkkU5Ez2I/rbCU8gBqsvcsBjcISu1mZDib9y
         ZrPuAlxQq6THDr8Tm6BXFyhYJJFwBh/dI3/baUkihqpSlFp4et9qo3ooed0acHfGzKHP
         0O6vroJ9KF8QGEaKLq/gcXmxOg54ro2pfpSzV3Kgkgh4stoGigASw6pmriJGyzWbDONN
         LlenutHeGuGL3LBbqeMniu2jHEWNqpsgZVkPzFXsmXhR7nKjxQjoC2X/+VKTFrVaWuu1
         GFUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=dSPA45Xd;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id d42si6041973jak.118.2019.02.11.14.46.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 14:46:08 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=dSPA45Xd;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1BMhVEI072777;
	Mon, 11 Feb 2019 22:44:50 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : mime-version : content-transfer-encoding;
 s=corp-2018-07-02; bh=Phi3yo5tGmVy0t3cuMS6IWQIWpdGP9aDbdf7nHYEaVU=;
 b=dSPA45Xdtxu6Z+Dit8MpYT+2EEXMoS2OYxCbo5qFygIAgtfMhwLWimjbpu6roq5OhjY0
 03EpjfiBvqMwMfBMAp57e7VJmclU/as0otGXzAMM9YUcv+18kFe47aLQCFGzYOfJtTsN
 2MzrrXcXLndV08bOkKsdZZczHP55rAI/s8yGOF9TsHEBordy7zWJ8ENOV2m4ty+cOmrn
 4kJtoz4bF9VbZrTThQvL7M4pxrEoKkxLVAnDpWllM4KoL6/nlkO6zRcQ89Z2niBYKWDZ
 VxijvUlOImfGrr2tI3Q0cDnpVui5UCSEL4Ha1M8N0cM7IZm9fpGzvzNg5aZRDtxLXgjt 8Q== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2qhrek8q7r-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 11 Feb 2019 22:44:50 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1BMimFO012607
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 11 Feb 2019 22:44:48 GMT
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1BMih6b013811;
	Mon, 11 Feb 2019 22:44:43 GMT
Received: from localhost.localdomain (/73.60.114.248)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 11 Feb 2019 14:44:43 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: jgg@ziepe.ca
Cc: akpm@linux-foundation.org, dave@stgolabs.net, jack@suse.cz, cl@linux.com,
        linux-mm@kvack.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
        linux-kernel@vger.kernel.org, alex.williamson@redhat.com,
        paulus@ozlabs.org, benh@kernel.crashing.org, mpe@ellerman.id.au,
        hao.wu@intel.com, atull@kernel.org, mdf@kernel.org, aik@ozlabs.ru,
        daniel.m.jordan@oracle.com
Subject: [PATCH 0/5] use pinned_vm instead of locked_vm to account pinned pages
Date: Mon, 11 Feb 2019 17:44:32 -0500
Message-Id: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9164 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902110162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000004, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

This series converts users that account pinned pages with locked_vm to
account with pinned_vm instead, pinned_vm being the correct counter to
use.  It's based on a similar patch I posted recently[0].

The patches are based on rdma/for-next to build on Davidlohr Bueso's
recent conversion of pinned_vm to an atomic64_t[1].  Seems to make some
sense for these to be routed the same way, despite lack of rdma content?

All five of these places, and probably some of Davidlohr's conversions,
probably want to be collapsed into a common helper in the core mm for
accounting pinned pages.  I tried, and there are several details that
likely need discussion, so this can be done as a follow-on.

I'd appreciate a look at patch 5 especially since the accounting is
unusual no matter whether locked_vm or pinned_vm are used.

On powerpc, this was cross-compile tested only.

[0] http://lkml.kernel.org/r/20181105165558.11698-8-daniel.m.jordan@oracle.com
[1] http://lkml.kernel.org/r/20190206175920.31082-1-dave@stgolabs.net

Daniel Jordan (5):
  vfio/type1: use pinned_vm instead of locked_vm to account pinned pages
  vfio/spapr_tce: use pinned_vm instead of locked_vm to account pinned
    pages
  fpga/dlf/afu: use pinned_vm instead of locked_vm to account pinned
    pages
  powerpc/mmu: use pinned_vm instead of locked_vm to account pinned
    pages
  kvm/book3s: use pinned_vm instead of locked_vm to account pinned pages

 Documentation/vfio.txt              |  6 +--
 arch/powerpc/kvm/book3s_64_vio.c    | 35 +++++++---------
 arch/powerpc/mm/mmu_context_iommu.c | 43 ++++++++++---------
 drivers/fpga/dfl-afu-dma-region.c   | 50 +++++++++++-----------
 drivers/vfio/vfio_iommu_spapr_tce.c | 64 ++++++++++++++---------------
 drivers/vfio/vfio_iommu_type1.c     | 31 ++++++--------
 6 files changed, 104 insertions(+), 125 deletions(-)

-- 
2.20.1

