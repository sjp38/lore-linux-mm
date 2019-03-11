Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F646C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 11:48:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BAD320657
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 11:48:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BAD320657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8A348E001A; Mon, 11 Mar 2019 07:48:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B10A38E0002; Mon, 11 Mar 2019 07:48:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D8308E001A; Mon, 11 Mar 2019 07:48:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 622DF8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 07:48:04 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id b21so2623949otl.7
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 04:48:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=ekXZhW+De4PINV6+xauW0II8wBM7JjpDOUhNFDBtmZ4=;
        b=tEj20TcRYTxgGAab1ZLx8mrmwOkj4slR3wF/S2B95YQa09uKmkmCglj5Qdg0Q6SVQg
         OCdqDYFToolK/EhGjhN3dcyV6Za6TzKlOLe8J4zjOWUN5oXBZbgZWb87EQXiMQ++Hx8E
         LOUol3FVUeu+rUs1JJvkRIkkMCuHJRj02RRJn+HFiOwVJ8hsuI/jsximzoYzp7/BnmyW
         llXRpTQ7uMQGP45hU/H7tkIkmhSGdMWwtgGAiqUJjRxSWxkpbiDwQiRzSKE8ShLOI95w
         W8/Fdm91ZL5PG2DD36P40y9rXzfs92DnUzqBSO+v1vpHN7vphVEFx7mMrF0NznrRU39v
         q5rQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAWNa5/ppcakg83D+b3+5mOalOLRipOKvvi2SHrKqsIowear+q1A
	r9A/bQqMJhLK58TBfADN4QO6rQqmbjo36IZbxgeqVOwWw1eRigKZ1dWuhF/Oe0S/BUhBjaDK6Oi
	Eb1ASlOTUH8rvTm08a/gq2JIgNMsFvjCaGpe2L6j4M8plJnXF7kgsaNaWlz0Ejb8wDQ==
X-Received: by 2002:a05:6830:10cd:: with SMTP id z13mr20696224oto.57.1552304884038;
        Mon, 11 Mar 2019 04:48:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyxNny0Q5xywEUK0NQNPcqgo99UdvCb33oXGpiHj4G/3cXgRwSHqdT9eEcVKliLYLLe2BLX
X-Received: by 2002:a05:6830:10cd:: with SMTP id z13mr20696175oto.57.1552304882901;
        Mon, 11 Mar 2019 04:48:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552304882; cv=none;
        d=google.com; s=arc-20160816;
        b=xNW2nZ2Gv2ONL9p3eYxTsOP2WnUp7Z8OE2c0isuRz+JiGtlPVPFzcP/fvpR/rSlnFh
         3Em8fMCQWiKqF9j7ZVsvx3gktitN9xOdDWJHLGJnf7UPiUrX0LUXVYIG5EcuiINruPxc
         UqtIAqkyLxVM87loNc4g3yY7mil+nCNYyKvfe7R/RNaCiCH63Sk1DovCeUzs5EpXY/iz
         FqQtqQ7YsmfvhSTedhglOkYcxBOv6rBfnHa7vNBuFg5ize0rB3mVJy4yhedQ8FIk/TJD
         ZhUk5A9yxJ00aO5xQTXaighFMFrIoUcndCqMGHjHWtIU38F5Pasp0jy4Rnu4rLmynuId
         0vFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=ekXZhW+De4PINV6+xauW0II8wBM7JjpDOUhNFDBtmZ4=;
        b=PH0mDzoe0wVtWWwfU9Db171OMf1x3kClJy2S7JH3B+0a8ubBeIhEx+b4UcV1eQXOiG
         AgDS8LTTWF2i5L2zyP0uFM+jEk9pTD4nhFHiakbnpaeWYMG6fJyQu5F6EZyMTbTBF/KM
         vwjfbAneu9KEA7hzH4/eQ0wYi5DTsXPfoOXypViCoElAej3UC8H1YarHdhM7qUE1Hcjw
         BuA6gcuknK+3rIw9Gz2kek/6ZT7e7x6O8/kRzIio69tro1LNsAp5uqd+JZ/cigeTpDLF
         aGNgH/AU09yffNC55NGFs+/1838/k8NRRVYptGe/jNq9nrc55KwMBY85rPh1N55jMuSA
         bq1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id 22si2462243otj.313.2019.03.11.04.48.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 04:48:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id ED20CA4C898C32F3FBC6;
	Mon, 11 Mar 2019 19:47:55 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS414-HUB.china.huawei.com
 (10.3.19.214) with Microsoft SMTP Server id 14.3.408.0; Mon, 11 Mar 2019
 19:47:47 +0800
Date: Mon, 11 Mar 2019 11:47:37 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Keith Busch <keith.busch@intel.com>
CC: <linux-kernel@vger.kernel.org>, <linux-acpi@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-api@vger.kernel.org>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, "Dave
 Hansen" <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>,
	<linuxarm@huawei.com>
Subject: Re: [PATCHv7 00/10] Heterogenous memory node attributes
Message-ID: <20190311114459.00006f3d@huawei.com>
In-Reply-To: <20190227225038.20438-1-keith.busch@intel.com>
References: <20190227225038.20438-1-keith.busch@intel.com>
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

On Wed, 27 Feb 2019 15:50:28 -0700
Keith Busch <keith.busch@intel.com> wrote:

> == Changes since v6 ==
> 
>   Updated to linux-next, which has a change to the HMAT structures to
>   account for ACPI revision 6.3.
> 
>   Changed memory-side cache "associativity" attribute to "indexing"
> 
> 
> Regarding the Kconfig, I am having the implementation specific as a user
> selectable option, and the generic interface, HMEM_REPORTING, is not a
> user prompt. I just wanted to clarify the point that there's only one.
> 
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
> existing tools and libraries. Those applications may query performance
> attributes relative to a particular CPU they're running on in order to
> make more informed choices for where they want to allocate hot and cold
> data. This works with mbind() or the numactl library.

Hi Keith,

Great to see this 'nearly' good to go.

For those that were too small / trivial to deserve a reviewed-by
Acked-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>

Subject to that one tweak in patch 7,
Tested-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>

Note that my tests were very limited for the memory-side caches
and not exactly comprehensive for the access attributes either.

They focused on the cases I care about rather than putting together
a fuller test suite.  That is probably worth doing at some point though
not sure I'll get to it any time soon.

Thanks,

Jonathan

> 
> Keith Busch (10):
>   acpi: Create subtable parsing infrastructure
>   acpi: Add HMAT to generic parsing tables
>   acpi/hmat: Parse and report heterogeneous memory
>   node: Link memory nodes to their compute nodes
>   node: Add heterogenous memory access attributes
>   node: Add memory-side caching attributes
>   acpi/hmat: Register processor domain to its memory
>   acpi/hmat: Register performance attributes
>   acpi/hmat: Register memory side cache attributes
>   doc/mm: New documentation for memory performance
> 
>  Documentation/ABI/stable/sysfs-devices-node   |  87 +++-
>  Documentation/admin-guide/mm/numaperf.rst     | 164 +++++++
>  arch/arm64/kernel/acpi_numa.c                 |   2 +-
>  arch/arm64/kernel/smp.c                       |   4 +-
>  arch/ia64/kernel/acpi.c                       |  14 +-
>  arch/x86/kernel/acpi/boot.c                   |  36 +-
>  drivers/acpi/Kconfig                          |   1 +
>  drivers/acpi/Makefile                         |   1 +
>  drivers/acpi/hmat/Kconfig                     |  11 +
>  drivers/acpi/hmat/Makefile                    |   1 +
>  drivers/acpi/hmat/hmat.c                      | 670 ++++++++++++++++++++++++++
>  drivers/acpi/numa.c                           |  16 +-
>  drivers/acpi/scan.c                           |   4 +-
>  drivers/acpi/tables.c                         |  76 ++-
>  drivers/base/Kconfig                          |   8 +
>  drivers/base/node.c                           | 352 +++++++++++++-
>  drivers/irqchip/irq-gic-v2m.c                 |   2 +-
>  drivers/irqchip/irq-gic-v3-its-pci-msi.c      |   2 +-
>  drivers/irqchip/irq-gic-v3-its-platform-msi.c |   2 +-
>  drivers/irqchip/irq-gic-v3-its.c              |   6 +-
>  drivers/irqchip/irq-gic-v3.c                  |  10 +-
>  drivers/irqchip/irq-gic.c                     |   4 +-
>  drivers/mailbox/pcc.c                         |   2 +-
>  include/linux/acpi.h                          |   6 +-
>  include/linux/node.h                          |  72 ++-
>  25 files changed, 1487 insertions(+), 66 deletions(-)
>  create mode 100644 Documentation/admin-guide/mm/numaperf.rst
>  create mode 100644 drivers/acpi/hmat/Kconfig
>  create mode 100644 drivers/acpi/hmat/Makefile
>  create mode 100644 drivers/acpi/hmat/hmat.c
> 


