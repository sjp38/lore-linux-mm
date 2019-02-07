Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48D6BC282CC
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 09:54:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0005A20823
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 09:54:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0005A20823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CA6C8E0023; Thu,  7 Feb 2019 04:54:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 878918E0002; Thu,  7 Feb 2019 04:54:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78EC28E0023; Thu,  7 Feb 2019 04:54:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 42D318E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 04:54:04 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id o8so8765298otp.16
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 01:54:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=2bAOg54bU0s40n5vMKn/MlPmJaBL62ACkVvGNXF8SHI=;
        b=KrYK3hJ4epb8Cpf9ld5RMcCY36pa+uzenmoZMElw0bFMfeNmLmq0cztTECdQ4ZR8vt
         KaQma9lq3uiYakNVYZDJPRxU+9fbGezBt067lTLCmL1zVTXmSpAOKoKMl7lzbA12TENk
         m9aVnXl9bhMzlaUvHM4DvDTJapa31pjfbBhhOrGuDmxMEOcadU0I29Hjr6FL4A5gBuvs
         uFexBSKXIoydDLtQoc0kIIbTdFEp4p1aNFfLb3W/1eHK2jU9C7P/wJ6YaTi9wgxq2HPL
         j/5q9Vr2oAN+c1h29l0eOO7zWqBk7MG6aDftiqnU4lrq3lfSbz77kacw55GUH9yLUYL/
         QmHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAuaUhzv0S5bctG+X9BBuVD1zbXjzhseNMkoaux4kEwr5uzqusoyp
	PfJ3em1MAyCqd8Cyv4UNCsgYuo0nwdidfVhWsV44OktQb0HFoRiJnTM2vFwfPbnIejQhyySCxAx
	JcqAiL7MWm5rT9ush7wSw1psNJCPP68yXzYEoLr0Bf3/F/8TPx54IIcYP7XQb/VEijA==
X-Received: by 2002:a9d:5549:: with SMTP id h9mr7730075oti.83.1549533243932;
        Thu, 07 Feb 2019 01:54:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbjnzMpYmlf8eNCg30B7Dn8d0pLSA/iitldNIgmMeUbLqfmb0T+0PT6UpSB/Svm82Xj9+eo
X-Received: by 2002:a9d:5549:: with SMTP id h9mr7730046oti.83.1549533242932;
        Thu, 07 Feb 2019 01:54:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549533242; cv=none;
        d=google.com; s=arc-20160816;
        b=MKlC1IxZJuuIdSE58H5r/iiWSmjK8U/BIZJeaQGvr963H8QrWn5TXAa9RDlro0qb3g
         6zrUHbmEWHvnuJfT9AsWsGxyT2Ohtgy0OxcyUaioaYLpTkmo3O0B3aPRNCes6hhH7DYL
         bzPO/AYqa2ZHux1OkAND63MyJNRhd2HbWjHnAyhoHPrq5Yh1EN5Bt0gi11b9t8wme41D
         joZKESkM3NVHfb8DTvy1PQL87EVCR/oUK/dQmrT2DQgzE5U6oF4EwNMSjSFn0B9UNyyG
         bdIqr/paGBfKp9f8VFe2QhAIwSIrM1qqPeB6yg8g6WTG7gtwjqK0lWzEUgnF3qlGd/pu
         wVfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=2bAOg54bU0s40n5vMKn/MlPmJaBL62ACkVvGNXF8SHI=;
        b=014hEpzI/Zl69yqOR8PsN/jL7Gh8J4XcofW+OGXL7bPuZ72mMTR79Yc/bxT70gx2iB
         Cd6fXdWm4ylMSkJO4kGVmbWXo97QXlSzN6cfpmONbOBoYAdiw26lnLCALb50PwppWs/6
         JXCdObgykI6tl+MWU5R6XBApBZ6BudXfD8BkByhVEtqQyUH3n49NwPRm7U9VB3ty072C
         MwWXjpSuFNArIoK4E1fVAjtk6612H3JYXxLGISUTXEDti+2UWth2VHSl1CeoVA26Hqtv
         IyIKjCjj1vpFGBnNCrkjDW7cPRHXotTnfQ50pHLnEt332KaT7902PzSkva8LpxSrHAYw
         LQ6g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id i17si333911otf.36.2019.02.07.01.54.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 01:54:02 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 89CA8EC8D4B0CDB62978;
	Thu,  7 Feb 2019 17:53:59 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS414-HUB.china.huawei.com
 (10.3.19.214) with Microsoft SMTP Server id 14.3.408.0; Thu, 7 Feb 2019
 17:53:50 +0800
Date: Thu, 7 Feb 2019 09:53:36 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Keith Busch <keith.busch@intel.com>, <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, <linux-acpi@vger.kernel.org>, "Greg
 Kroah-Hartman" <gregkh@linuxfoundation.org>, Rafael Wysocki
	<rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams
	<dan.j.williams@intel.com>, <linuxarm@huawei.com>
Subject: Re: [PATCHv5 00/10] Heterogeneuos memory node attributes
Message-ID: <20190207095336.0000529f@huawei.com>
In-Reply-To: <20190124230724.10022-1-keith.busch@intel.com>
References: <20190124230724.10022-1-keith.busch@intel.com>
Organization: Huawei
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 24 Jan 2019 16:07:14 -0700
Keith Busch <keith.busch@intel.com> wrote:

> == Changes since v4 ==
> 
>   All public interfaces have kernel docs.
> 
>   Renamed "class" to "access", docs and changed logs updated
>   accordingly. (Rafael)
> 
>   The sysfs hierarchy is altered to put initiators and targets in their
>   own attribute group directories (Rafael).
> 
>   The node lists are removed. This feedback is in conflict with v1
>   feedback, but consensus wants to remove multi-value sysfs attributes,
>   which includes lists. We only have symlinks now, just like v1 provided.
> 
>   Documentation and code patches are combined such that the code
>   introducing new attributes and its documentation are in the same
>   patch. (Rafael and Dan).
> 
>   The performance attributes, bandwidth and latency, are moved into the
>   initiators directory. This should make it obvious for which node
>   access the attributes apply, which was previously ambiguous.
>   (Jonathan Cameron).
> 
>   The HMAT code selecting "local" initiators is substantially changed.
>   Only PXM's that have identical performance to the HMAT's processor PXM
>   in Address Range Structure are registered. This is to avoid considering
>   nodes identical when only one of several perf attributes are the same.
>   (Jonathan Cameron).
> 
>   Verbose variable naming. Examples include "initiator" and "target"
>   instead of "i" and "t", "mem_pxm" and "cpu_pxm" instead of "m" and
>   "p". (Rafael)
> 
>   Compile fixes for when HMEM_REPORTING is not set. This is not a user
>   selectable config option, default 'n', and will have to be selected
>   by other config options that require it (Greg KH and Rafael).
> 
> == Background ==
> 
> Platforms may provide multiple types of cpu attached system memory. The
> memory ranges for each type may have different characteristics that
> applications may wish to know about when considering what node they want
> their memory allocated from. 
> 
> It had previously been difficult to describe these setups as memory
> rangers were generally lumped into the NUMA node of the CPUs. New
> platform attributes have been created and in use today that describe
> the more complex memory hierarchies that can be created.
> 
> This series' objective is to provide the attributes from such systems
> that are useful for applications to know about, and readily usable with
> existing tools and libraries.

As a general heads up, ACPI 6.3 is out and makes some changes.
Discussions I've had in the past suggested there were few systems
shipping with 6.2 HMAT and that many firmwares would start at 6.3.
Of course, that might not be true, but there was fairly wide participation
in the meeting so fingers crossed it's accurate.

https://uefi.org/sites/default/files/resources/ACPI_6_3_final_Jan30.pdf

Particular points to note:
1. Most of the Memory Proximity Domain Attributes Structure was deprecated.
   This includes the reservation hint which has been replaced
   with a new mechanism (not used in this patch set)

2. Base units for latency changed to picoseconds.  There is a lot more
   explanatory text around how those work.

3. The measurements of latency and bandwidth no longer have an
   'aggregate performance' version.  Given the work load was not described
   this never made any sense.  Better for a knowledgeable bit of software
   to work out it's own estimate.

4. There are now Generic Initiator Domains that have neither memory nor
   processors.  I'll come back with proposals on handling those soon if
   no one beats me to it. (I think it's really easy but may be wrong ;)
   I've not really thought out how this series applies to GI only domains
   yet.  Probably not useful to know you have an accelerator near to
   particular memory if you are deciding where to pin your host processor
   task ;)

Jonathan

> 
> Keith Busch (10):
>   acpi: Create subtable parsing infrastructure
>   acpi: Add HMAT to generic parsing tables
>   acpi/hmat: Parse and report heterogeneous memory
>   node: Link memory nodes to their compute nodes
>   acpi/hmat: Register processor domain to its memory
>   node: Add heterogenous memory access attributes
>   acpi/hmat: Register performance attributes
>   node: Add memory caching attributes
>   acpi/hmat: Register memory side cache attributes
>   doc/mm: New documentation for memory performance
> 
>  Documentation/ABI/stable/sysfs-devices-node   |  87 ++++-
>  Documentation/admin-guide/mm/numaperf.rst     | 167 ++++++++
>  arch/arm64/kernel/acpi_numa.c                 |   2 +-
>  arch/arm64/kernel/smp.c                       |   4 +-
>  arch/ia64/kernel/acpi.c                       |  12 +-
>  arch/x86/kernel/acpi/boot.c                   |  36 +-
>  drivers/acpi/Kconfig                          |   1 +
>  drivers/acpi/Makefile                         |   1 +
>  drivers/acpi/hmat/Kconfig                     |   9 +
>  drivers/acpi/hmat/Makefile                    |   1 +
>  drivers/acpi/hmat/hmat.c                      | 537 ++++++++++++++++++++++++++
>  drivers/acpi/numa.c                           |  16 +-
>  drivers/acpi/scan.c                           |   4 +-
>  drivers/acpi/tables.c                         |  76 +++-
>  drivers/base/Kconfig                          |   8 +
>  drivers/base/node.c                           | 354 ++++++++++++++++-
>  drivers/irqchip/irq-gic-v2m.c                 |   2 +-
>  drivers/irqchip/irq-gic-v3-its-pci-msi.c      |   2 +-
>  drivers/irqchip/irq-gic-v3-its-platform-msi.c |   2 +-
>  drivers/irqchip/irq-gic-v3-its.c              |   6 +-
>  drivers/irqchip/irq-gic-v3.c                  |  10 +-
>  drivers/irqchip/irq-gic.c                     |   4 +-
>  drivers/mailbox/pcc.c                         |   2 +-
>  include/linux/acpi.h                          |   6 +-
>  include/linux/node.h                          |  60 ++-
>  25 files changed, 1344 insertions(+), 65 deletions(-)
>  create mode 100644 Documentation/admin-guide/mm/numaperf.rst
>  create mode 100644 drivers/acpi/hmat/Kconfig
>  create mode 100644 drivers/acpi/hmat/Makefile
>  create mode 100644 drivers/acpi/hmat/hmat.c
> 


