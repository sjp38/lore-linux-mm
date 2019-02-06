Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EC91C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 12:31:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDB7120B1F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 12:31:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDB7120B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A2E68E00BE; Wed,  6 Feb 2019 07:31:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9585A8E00AA; Wed,  6 Feb 2019 07:31:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81C8D8E00BE; Wed,  6 Feb 2019 07:31:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4A2D18E00AA
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 07:31:37 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id o13so5931935otl.20
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 04:31:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=TkE/UyzBpFOtT1q9zjRuvvdHy00SxsrY516EAb8kFkM=;
        b=EM+nSAHf5ONaiEfaB3QlkwrgGGhYMcw7HzvTIDFVOFPlKMNNagbFd3hq+yzCcgXnpR
         lUYXLEhsbQOTvqMO4EtAhUbvNjJ5sTbMFVwLk13UMHpjrhXhAHFyxIHawBieHE0FH2tq
         5r8j9KBPNP24f5LCKK84e0/GNowVlswhofUNqj7EFLCUUD9Hl9NdkcSqB+f+BE6WKDEx
         lW/Uowwfx/NYs6IGZOx+nGYH5KA0syGuBoI08O9DFXS0Ixh8FLvU1N0fdFwq8TfzRgG5
         mpIkAwb2FiZzk1lbAjny0q0lEvW3gTMsYbS6zaoRpnTbD2ifKXHBcViw994bgp5D2QcB
         7aVw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAuafnBDYSKNcQ/5iV3hK0fKt9BrnoHGkLWGPt5msh/ST4QZ4qBCw
	+LLsCYX/ZtfILNyCbuCSvvBc04jGngFbyuM4/l2csIS8q659vQqhmBDhKMfBmUN4Gf9ehFgd/ZU
	FGpju8TniyGn3hp9+mtgoaCcuug2/k+tesRCKFqjN+rCxxy/6P8AM2fxoVvsRPb+EdQ==
X-Received: by 2002:aca:db86:: with SMTP id s128mr2491438oig.328.1549456296958;
        Wed, 06 Feb 2019 04:31:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY5Am2fV5b5Eu2q+FhHSoM8jyaHbUkAhNj29OeLenHYJEUJKBfbV5eLVaj811n6lFcPE4Jv
X-Received: by 2002:aca:db86:: with SMTP id s128mr2491403oig.328.1549456296007;
        Wed, 06 Feb 2019 04:31:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549456296; cv=none;
        d=google.com; s=arc-20160816;
        b=PHZeRklJ1/PoSccgQPDYhOWqquxP5nmLqIigIZ2tbILCO0FL+OkBi+jdWLo8u0l5Ud
         bXIHS3xtLZDngi4XBy2FNYPUKrgwrFW2/CYBUMZQ5v3cQVe2Eg7pifeOZSq380zpMMD7
         qUP9nq0z9vRxv9BmNcvddAqiOtoXSgb7kZl8tTVAiQk8xq7S8NSdyvoD5+2qF0rEE/cv
         nY0ONUPUKT/KTENsCHX/sP5RH+DK3BtsNJUYpvb2TsJtCIzULPJZt2HlG0bV3+eCo/Gm
         Ew+pfTLTR0HhRSO0sGc5QInWokZs8ArFgP0FK9UAPRDpLhrhWsk4id/HMzpXvosduSOT
         2PIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=TkE/UyzBpFOtT1q9zjRuvvdHy00SxsrY516EAb8kFkM=;
        b=fMbQtO1th5eKK00fA76Yg26oMWb3oG6pYkU9CBjcp2OugmeqOoj1hHk3FaEv/C5z/G
         jXk7SSFlGuRekkcqKJTR/9LRnp/vnzZlwRBbMwvfzczFIOhFG8sLEX52yrkvp8e9AB5k
         OPvxiR4HE+cxONiHy3ulD03jDkNqIfZ3/rZHMtK27O0eb2uKSBX2VM1Ln9g046M8UlTL
         CAaZMfLFLMyUV1GVOx5dEoHtairr140mxIzagQEBJviz3EDFMCzfHkbwhZlUawKcBDZx
         g4Ef8EwSXahBjFPM2r1StNOJ0V3C8LWtspZ8HOfKxr1MbNAIvgR5rkUKy8Wr/Y8+jpiD
         Xy4g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id l135si9439148oih.146.2019.02.06.04.31.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 04:31:35 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS410-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 3812BA6B04A7DDE2C50F;
	Wed,  6 Feb 2019 20:31:22 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS410-HUB.china.huawei.com
 (10.3.19.210) with Microsoft SMTP Server id 14.3.408.0; Wed, 6 Feb 2019
 20:31:11 +0800
Date: Wed, 6 Feb 2019 12:31:00 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Keith Busch <keith.busch@intel.com>
CC: <linux-kernel@vger.kernel.org>, <linux-acpi@vger.kernel.org>,
	<linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
	"Dan Williams" <dan.j.williams@intel.com>, <linuxarm@huawei.com>
Subject: Re: [PATCHv5 00/10] Heterogeneuos memory node attributes
Message-ID: <20190206123100.0000094a@huawei.com>
In-Reply-To: <20190124230724.10022-1-keith.busch@intel.com>
References: <20190124230724.10022-1-keith.busch@intel.com>
Organization: Huawei
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; i686-w64-mingw32)
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

Hi Keith,

Seems to be heading in the right direction to me... (though I personally
want to see the whole of HMAT expose, but meh, that seems unpopular :)

I've fired up a new test rig (someone pinched the fan on the previous one)
that I can make present pretty much anything to this code.

First up is a system with 4 nodes with cpu and local ddr [0-3] + 1 remote node
with just memory [4]. All the figures as you might expect between the nodes with
CPUs. The remote node has equal numbers from all the cpus.

First some general comments on places this doesn't work as my gut feeling
said it would...

I'm going to keep this somewhat vague on certain points as ACPI 6.3 should
be public any day now and I think it is fair to say we should take into
account any changes in there...
There is definitely one place the current patches won't work with 6.3, but
I'll point it out in a few days.  There may be others.

1) It seems this version added a hard dependence on having the memory node
   listed in the Memory Proximity Domain attribute structures.  I'm not 100%
   sure there is actually any requirement to have those structures. If you aren't
   using the hint bit, they don't convey any information.  It could be argued
   that they provide info on what is found in the other hmat entries, but there
   is little purpose as those entries are explicit in what the provide.
   (Given I didn't have any of these structures and things  worked fine with
    v4 it seems this is a new check).

   This is also somewhat inconsistent.
   a) If a given entry isn't there, we still get for example
      node4/access0/initiators/[read|write]_* but all values are 0.
      If we want to do the check you have it needs to not create the files in
      this case.  Whilst they have no meaning as there are no initiators, it
      is inconsistent to my mind.

   b) Having one "Memory Proximity Domain attribute structure" for node 4 linking
      it to node0 is sufficient to allow
      node4/access0/initiators/node0
      node4/access0/initiators/node1
      node4/access0/initiators/node2
      node4/access0/initiators/node3
      I think if we are going to enforce the presence of that structure then only
      the node0 link should exist.

2) Error handling could perhaps do to spit out some nasty warnings.
   If we have an entry for nodes that don't exist we shouldn't just fail silently,
   that's just one example I managed to trigger with minor table tweaking.

Personally I would just get rid of enforcing anything based on the presence of
that structure.

I'll send more focused comments on some of the individual patches.

Thanks,

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


