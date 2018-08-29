Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 81FA36B4A77
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 03:20:32 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k16-v6so1856794ede.6
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 00:20:32 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d21-v6si2918165eds.170.2018.08.29.00.20.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Aug 2018 00:20:30 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w7T7J5ra029956
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 03:20:29 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2m5kwwprkf-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 03:20:29 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 29 Aug 2018 08:20:27 +0100
Date: Wed, 29 Aug 2018 10:20:19 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH RESEND 0/7] switch several architectures NO_BOOTMEM
References: <1533326330-31677-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1533326330-31677-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <20180829072019.GA13173@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Richard Kuo <rkuo@codeaurora.org>, Ley Foon Tan <lftan@altera.com>, Richard Weinberger <richard@nod.at>, Guan Xuetao <gxt@pku.edu.cn>, Michal Hocko <mhocko@kernel.org>, linux-hexagon@vger.kernel.org, nios2-dev@lists.rocketboards.org, linux-um@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Any updates on this?

On Fri, Aug 03, 2018 at 10:58:43PM +0300, Mike Rapoport wrote:
> 
> Hi,
> 
> These patches perform conversion to NO_BOOTMEM of hexagon, nios2, uml and
> unicore32. The architecture maintainers have acked the patches, but, since
> I've got no confirmation the patches are going through the arch tree I'd
> appreciate if the set would be applied to the -mm tree.
> 
> Mike Rapoport (7):
>   hexagon: switch to NO_BOOTMEM
>   of: ignore sub-page memory regions
>   nios2: use generic early_init_dt_add_memory_arch
>   nios2: switch to NO_BOOTMEM
>   um: setup_physmem: stop using global variables
>   um: switch to NO_BOOTMEM
>   unicore32: switch to NO_BOOTMEM
> 
>  arch/hexagon/Kconfig      |  3 +++
>  arch/hexagon/mm/init.c    | 20 +++++++-----------
>  arch/nios2/Kconfig        |  3 +++
>  arch/nios2/kernel/prom.c  | 17 ---------------
>  arch/nios2/kernel/setup.c | 39 ++++++----------------------------
>  arch/um/Kconfig.common    |  2 ++
>  arch/um/kernel/physmem.c  | 22 +++++++++----------
>  arch/unicore32/Kconfig    |  1 +
>  arch/unicore32/mm/init.c  | 54 +----------------------------------------------
>  drivers/of/fdt.c          | 11 +++++-----
>  10 files changed, 41 insertions(+), 131 deletions(-)
> 
> -- 
> 2.7.4
> 

-- 
Sincerely yours,
Mike.
