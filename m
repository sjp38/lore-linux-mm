Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B816C282C7
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 17:47:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04BA9214DA
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 17:47:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04BA9214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70FCB8E0002; Tue, 29 Jan 2019 12:47:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BF718E0001; Tue, 29 Jan 2019 12:47:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5ADC58E0002; Tue, 29 Jan 2019 12:47:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2D5CB8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 12:47:40 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id j5so25265364qtk.11
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 09:47:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=7t824AnphP/zqnjb4IosB6tDF0+Ohdb/AEh+UEV+FqI=;
        b=JjB7wQd3e10VfJweR1mW2Arnfy75kTdlE880neJbPuW8DmcAmSiJyF08gI/6aoM9Bo
         Jq0FNW+ufVPI5GRfKyPQm9HHwjagOM/ZTCQYJRZDJal4wMhA6A9hHlwpN3Jn2AgrVmMs
         AApViT66YF1fH9PcchO4OkCj0f5RgJtJjBqrJtXt4KTd7KCrhjYMSYS9awZJBOTYQ4us
         1HwmC4XW/+Op9TfayB59TGAu0zm/mv66w7JC5PPVCmIwrcALgWuDoSlrv5jo08kFAj35
         P6Z/koHPCzEoCNNQQ9JS+jirFKfdBRaRK/OW+zeRFatLpkhbWZOfLG5fo8a12t01rrUI
         Erlg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukegJUw4dqA3OBfsDFKTb0buepWxVT8ed15niBv8tTjTknBOeEK/
	K0jOWaKOYE0yJNYjNohutRCu8mzLeOzEsZrG+Wtipcb+bG9hnuERZQoxxjuSG4koe5cyDAWPPDE
	4ors1NV7Oj4dJuHbrYUYYZYEfnMmXQP5elMSNBStiol+6EkB7QKEp6UUrY3N/yrDVGw==
X-Received: by 2002:ac8:4884:: with SMTP id i4mr26346592qtq.219.1548784059920;
        Tue, 29 Jan 2019 09:47:39 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4Fp7DvRwcwaoiVrvb9S60cntL08M+DCHFcwOY2EHgyKYkNQmqnNLQHbOltuE/oFHC4a/kQ
X-Received: by 2002:ac8:4884:: with SMTP id i4mr26346552qtq.219.1548784059213;
        Tue, 29 Jan 2019 09:47:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548784059; cv=none;
        d=google.com; s=arc-20160816;
        b=bFxElqjR9/CrET6c7zCuHfg/diG2u++4nZ+Ba+V09v9HMjLpFvOt5rESX9SEEi0ric
         QBC8rgViqzWTNAbO+9vShER0+B0z4eS76DTBLmK3eOEhC5rw9jO8cuSu9xAmChgMgAWc
         FbAFAZv9ai5IvNK3hJFk1FJM3tSRbU4qjbsS4lERgQCtGudBUKyRKr0psRSqHkHeTXqH
         Nkd2va7yFIAE13Gq4Trsf/dos4iOvVR1G6+OXZBCvs+/gK/NJAkpgRlBfPEYCXd2TTFp
         AH6ddMkCcN5FCGJ1WiyEmFoPgky43BDshX1jrWvRNhUNTJg+OSl+9WwM20UnBcqht4wv
         9tMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=7t824AnphP/zqnjb4IosB6tDF0+Ohdb/AEh+UEV+FqI=;
        b=HfjoztIaarBYnH8rm13SlId+l1j7qOVC36JyLVGdWBqTM/LvrgDxmZXHJSKHGvcboG
         UyepHHbgmSt+LAkTRQseeHVfCp+R18gCImfy1gt7FE29G/AGgp3MTaB5avt/da2yZyFb
         AhRwGBMbe0422t/APsNUE1gE3dk0eakIoUU4UlB+Z22VOxDMFpxVIsxfgipZdJhnRNJk
         nBaU4XX9yR8EvpmRzhMCHr3BEUnFh8GDDuutghgTnlOdgreqicKBQbsYj5w2J9lGWnvd
         KVKV4D47oiD0v4oxE1mXmiSRSjfz5GWxlVeMb0v6gT7crFnLCyT8vH6RrSt+yrhqJlWH
         qNzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d2si3373652qtl.198.2019.01.29.09.47.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 09:47:39 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id ADC1D9B308;
	Tue, 29 Jan 2019 17:47:37 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0B55B5D97E;
	Tue, 29 Jan 2019 17:47:32 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	linux-pci@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Joerg Roedel <jroedel@suse.de>,
	iommu@lists.linux-foundation.org
Subject: [RFC PATCH 0/5] Device peer to peer (p2p) through vma
Date: Tue, 29 Jan 2019 12:47:23 -0500
Message-Id: <20190129174728.6430-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 29 Jan 2019 17:47:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

This patchset add support for peer to peer between device in two manner.
First for device memory use through HMM in process regular address space
(ie inside a regular vma that is not an mmap of device file or special
file). Second for special vma ie mmap of a device file, in this case some
device driver might want to allow other device to directly access memory
use for those special vma (not that the memory might not even be map to
CPU in this case).

They are many use cases for this they mainly fall into 2 category:
[A]-Allow device to directly map and control another device command
    queue.

[B]-Allow device to access another device memory without disrupting
    the other device computation.

Corresponding workloads:

[1]-Network device directly access an control a block device command
    queue so that it can do storage access without involving the CPU.
    This fall into [A]
[2]-Accelerator device doing heavy computation and network device is
    monitoring progress. Direct accelerator's memory access by the
    network device avoid the need to use much slower system memory.
    This fall into [B].
[3]-Accelerator device doing heavy computation and network device is
    streaming out the result. This avoid the need to first bounce the
    result through system memory (it saves both system memory and
    bandwidth). This fall into [B].
[4]-Chaining device computation. For instance a camera device take a
    picture, stream it to a color correction device that stream it
    to final memory. This fall into [A and B].

People have more ideas on how to use this than i can list here. The
intention of this patchset is to provide the means to achieve those
and much more.

I have done a testing using nouveau and Mellanox mlx5 where the mlx5
device can directly access GPU memory [1]. I intend to use this inside
nouveau and help porting AMD ROCm RDMA to use this [2]. I believe
other people have express interest in working on using this with
network device and block device.

From implementation point of view this just add 2 new call back to
vm_operations struct (for special device vma support) and 2 new call
back to HMM device memory structure for HMM device memory support.

For now it needs IOMMU off with ACS disabled and for both device to
be on same PCIE sub-tree (can not cross root complex). However the
intention here is different from some other peer to peer work in that
we do want to support IOMMU and are fine with going through the root
complex in that case. In other words, the bandwidth advantage of
avoiding the root complex is of less importance than the programming
model for the feature. We do actualy expect that this will be use
mostly with IOMMU enabled and thus with having to go through the root
bridge.

Another difference from other p2p solution is that we do require that
the importing device abide to mmu notifier invalidation so that the
exporting device can always invalidate a mapping at any point in time.
For this reasons we do not need a struct page for the device memory.

Also in all the cases the policy and final decision on wether to map
or not is solely under the control of the exporting device.

Finaly the device memory might not even be map to the CPU and thus
we have to go through the exporting device driver to get the physical
address at which the memory is accessible.

The core change are minimal (adding new call backs to some struct).
IOMMU support will need little change too. Most of the code is in
driver to implement export policy and BAR space management. Very gross
playground with IOMMU support in [3] (top 3 patches).

Cheers,
Jérôme

[1] https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-p2p
[2] https://github.com/RadeonOpenCompute/ROCnRDMA
[3] https://cgit.freedesktop.org/~glisse/linux/log/?h=wip-hmm-p2p

Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Rafael J. Wysocki <rafael@kernel.org>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Christian Koenig <christian.koenig@amd.com>
Cc: Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: linux-pci@vger.kernel.org
Cc: dri-devel@lists.freedesktop.org
Cc: Christoph Hellwig <hch@lst.de>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Robin Murphy <robin.murphy@arm.com>
Cc: Joerg Roedel <jroedel@suse.de>
Cc: iommu@lists.linux-foundation.org

Jérôme Glisse (5):
  pci/p2p: add a function to test peer to peer capability
  drivers/base: add a function to test peer to peer capability
  mm/vma: add support for peer to peer to device vma
  mm/hmm: add support for peer to peer to HMM device memory
  mm/hmm: add support for peer to peer to special device vma

 drivers/base/core.c        |  20 ++++
 drivers/pci/p2pdma.c       |  27 +++++
 include/linux/device.h     |   1 +
 include/linux/hmm.h        |  53 +++++++++
 include/linux/mm.h         |  38 +++++++
 include/linux/pci-p2pdma.h |   6 +
 mm/hmm.c                   | 219 ++++++++++++++++++++++++++++++-------
 7 files changed, 325 insertions(+), 39 deletions(-)

-- 
2.17.2

