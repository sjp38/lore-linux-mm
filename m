Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 781D3C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:58:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34BF02087F
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:58:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34BF02087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D50C08E0004; Tue, 29 Jan 2019 11:58:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFCB98E0002; Tue, 29 Jan 2019 11:58:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEC6A8E0004; Tue, 29 Jan 2019 11:58:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 986DA8E0002
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:58:48 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id 42so25072965qtr.7
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:58:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=4RtpYwDFFr6LuEfTx6X1rIILNtZpbTp/F1i5xvBvPw0=;
        b=AkVjyqEYgGV/+fnNe6gfdODpPB/Ft/kImrYwJO/IDOA0wDxyjpyEIbFI96jfmwv3CW
         1WOkfYDoOgghscmldrrGoxy+T9e8BUe4H5i0D81r1ODljnpfeCtnOhSbuf8+eWtYoDEJ
         MrT2duBjl/KRAsr4S66GkZ2ASglUvGl5nuJjikEBwZNZEwbAw0/Mq5GL+l/ecHgdK9H1
         39hgMIW7rQxpOaXTU334ZYyvVT/X02UURkE45SNMZ/ZWVioopVkl3V0Ql4VPx7g6xA3d
         9cQgsrSLNbJIacbT8vSPSYl0pSoYPZhGWCcGkRpX1nnZuVjE4sDlDevHosHKDo/L1qtD
         h6ig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukc2WMatvgeSQjfSlKBf/SuS3m4txF/U7bxbwzVgJFN1pe+NbXGi
	1FWWjPlwxC8NWZTS8MaE53L9Nuut6Qd70r5fu7lZyxAFuLIYKNDn8HRkLhOMqqii6vEHvmavq+v
	EnthpYZ1nFB7/ohFbXl5gBk9U7T1Roc7ByVkn16Ba3cQy1hxkRC6HwKakcjL3/SSKfw==
X-Received: by 2002:a37:9d10:: with SMTP id g16mr23327292qke.53.1548781128394;
        Tue, 29 Jan 2019 08:58:48 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6HlP9vGQW7in+OGj0Nv4LxA/7SUyOh4jpqKXP/bxlZBRCvA64jQ4QW9rSVBpq/TfcwCbZu
X-Received: by 2002:a37:9d10:: with SMTP id g16mr23327258qke.53.1548781127903;
        Tue, 29 Jan 2019 08:58:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548781127; cv=none;
        d=google.com; s=arc-20160816;
        b=N8orgvm49+CHdnCGMg2170YUbe/b71gShTYTV7CEedJYnQOpYtQEtMZWoZvZPMlat4
         BfS3yq7JBOPN0KRVRJ6h9q5rd3xXlxdgsf7aT2Tdkxn4qWYfKTKu9pnCHbkcGuawUy67
         ssCObc/r/XZJTg1KN5eIJ6oyvf9t44QtuSWUZYLrdg01Fz6XIuxUxJELaJPs2Yhb3IeC
         zFDAWAHNJuvg6KGwpjM8zkqOUSMvfYcH42j2e5bkEZnQkojL4+xqIYbbpRAophX5AQ7I
         xNTN26IdZ45P0CgEiFPIy/PjypW9Z81zqDh120Q1Waxjy0t+rJn1Ni+GwdJW45e0ACNJ
         jbVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=4RtpYwDFFr6LuEfTx6X1rIILNtZpbTp/F1i5xvBvPw0=;
        b=HDRW7PL92QKcRgl6fhbseOKYkxQuSP+DgJY66RPSD7JBXLt/PXQBjPqHasM4yjZgr3
         kn8EuX22KaGzv7LVPQwflg+d3AccCZyU2sKnlS/LSfR3H3mQk1DPxe81BiQTw1Pv4Ftg
         8i50y0kL4/jk5jSGnHxwrHL3T3WH1rcOAkB1FQhHrBa9Qs/KJQx0BrUzS6CkL2ec/Fo5
         L5+e8+v7K04Ojl5pYACUjW7vQVeL6VamIpEh4pxex6wfb4AEBKZCIA3K/2XRfIjkA3sP
         T+qZwZ0cWcgq5Y7v7IcfgfO9N3LHSxX0SoOG3VoS63GKv4Z6900yeb73wMhHBZ5iEWFx
         K7NQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p3si4694215qtp.114.2019.01.29.08.58.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 08:58:47 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E96B881F0B;
	Tue, 29 Jan 2019 16:58:46 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 632585F7E7;
	Tue, 29 Jan 2019 16:58:45 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	linux-rdma@vger.kernel.org,
	Jason Gunthorpe <jgg@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Artemy Kovalyov <artemyko@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Kaike Wan <kaike.wan@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>
Subject: [RFC PATCH 0/1] Use HMM for ODP
Date: Tue, 29 Jan 2019 11:58:38 -0500
Message-Id: <20190129165839.4127-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 29 Jan 2019 16:58:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

This patchset convert RDMA ODP to use HMM underneath this is motivated
by stronger code sharing for same feature (share virtual memory SVM or
Share Virtual Address SVA) and also stronger integration with mm code to
achieve that. It depends on HMM patchset posted for inclusion in 5.1 so
earliest target for this should be 5.2. I welcome any testing people can
do on this.

Moreover they are some features of HMM in the works like peer to peer
support, fast CPU page table snapshot, fast IOMMU mapping update ...
It will be easier for RDMA devices with ODP to leverage those if they
use HMM underneath.

Quick summary of what HMM is:
    HMM is a toolbox for device driver to implement software support for
    Share Virtual Memory (SVM). Not only it provides helpers to mirror a
    process address space on a device (hmm_mirror). It also provides
    helper to allow to use device memory to back regular valid virtual
    address of a process (any valid mmap that is not an mmap of a device
    or a DAX mapping). They are two kinds of device memory. Private memory
    that is not accessible to CPU because it does not have all the expected
    properties (this is for all PCIE devices) or public memory which can
    also be access by CPU without restriction (with OpenCAPI or CCIX or
    similar cache-coherent and atomic inter-connect).

    Device driver can use each of HMM tools separatly. You do not have to
    use all the tools it provides.

For RDMA device i do not expect a need to use the device memory support
of HMM. This device memory support is geared toward accelerator like GPU.


You can find a branch [1] with all the prerequisite in. This patch is on
top of 5.0rc2+ but i can rebase it on any specific branch before it is
consider for inclusion (5.2 at best).

Questions and reviews are more than welcome.

[1] https://cgit.freedesktop.org/~glisse/linux/log/?h=odp-hmm
[2] https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-for-5.1

Cc: linux-rdma@vger.kernel.org
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Leon Romanovsky <leonro@mellanox.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Artemy Kovalyov <artemyko@mellanox.com>
Cc: Moni Shoua <monis@mellanox.com>
Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>
Cc: Kaike Wan <kaike.wan@intel.com>
Cc: Dennis Dalessandro <dennis.dalessandro@intel.com>

Jérôme Glisse (1):
  RDMA/odp: convert to use HMM for ODP

 drivers/infiniband/core/umem_odp.c | 483 ++++++++---------------------
 drivers/infiniband/hw/mlx5/mem.c   |  20 +-
 drivers/infiniband/hw/mlx5/mr.c    |   2 +-
 drivers/infiniband/hw/mlx5/odp.c   |  95 +++---
 include/rdma/ib_umem_odp.h         |  54 +---
 5 files changed, 202 insertions(+), 452 deletions(-)

-- 
2.17.2

