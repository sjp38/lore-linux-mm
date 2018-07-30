Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7594C6B0003
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 02:14:51 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id c18-v6so10104847oiy.3
        for <linux-mm@kvack.org>; Sun, 29 Jul 2018 23:14:51 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c131-v6si7228416oif.456.2018.07.29.23.14.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jul 2018 23:14:50 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6U69L0T139335
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 02:14:49 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2khva09rqc-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 02:14:49 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 30 Jul 2018 07:14:47 +0100
Date: Mon, 30 Jul 2018 09:14:40 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/3] nios2: switch to NO_BOOTMEM
References: <1530710295-10774-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530710295-10774-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <20180730061439.GB15948@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ley Foon Tan <lftan@altera.com>
Cc: Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Michal Hocko <mhocko@kernel.org>, nios2-dev@lists.rocketboards.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Any updates on this?

On Wed, Jul 04, 2018 at 04:18:12PM +0300, Mike Rapoport wrote:
> These patches switch nios2 boot time memory allocators from bootmem to
> memblock + no_bootmem.
> 
> As nios2 uses fdt, the conversion is pretty much about actually using the
> existing fdt infrastructure for the early memory management.
> 
> The first patch in the series is not strictly related to nios2. It's just
> I've got really interesting memory layout without it because of 1K long
> memory ranges defined in arch/nios2/boot/dts/10m50_devboard.dts.
> 
> Mike Rapoport (3):
>   of: ignore sub-page memory regions
>   nios2: use generic early_init_dt_add_memory_arch
>   nios2: switch to NO_BOOTMEM
> 
>  arch/nios2/Kconfig        |  3 +++
>  arch/nios2/kernel/prom.c  | 17 -----------------
>  arch/nios2/kernel/setup.c | 39 +++++++--------------------------------
>  drivers/of/fdt.c          | 11 ++++++-----
>  4 files changed, 16 insertions(+), 54 deletions(-)
> 
> -- 
> 2.7.4
> 

-- 
Sincerely yours,
Mike.
