Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 769038E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 07:27:54 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id q12-v6so16166495otf.20
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 04:27:54 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v13-v6si2661385ote.41.2018.09.26.04.27.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 04:27:53 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8QBOOtV086589
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 07:27:52 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mr7ud43pe-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 07:27:52 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 26 Sep 2018 12:27:50 +0100
Date: Wed, 26 Sep 2018 14:27:45 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] csky: fixups after bootmem removal
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Message-Id: <20180926112744.GC4628@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Guo Ren <ren_guo@c-sky.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

The below patch fixes the bootmem leftovers in csky. It is based on the
current mmots and csky build there fails because of undefined reference to
dma_direct_ops:

  MODPOST vmlinux.o
kernel/dma/mapping.o: In function `dmam_alloc_attrs':
kernel/dma/mapping.c:143: undefined reference to `dma_direct_ops'
kernel/dma/mapping.o: In function `dmam_declare_coherent_memory':
kernel/dma/mapping.c:184: undefined reference to `dma_direct_ops'
mm/dmapool.o: In function `dma_free_attrs': 
include/linux/dma-mapping.h:558: undefined reference to `dma_direct_ops'

I've blindly added "select DMA_DIRECT_OPS" to arch/csky/Kconfig and it
fixed the build, but I really have no idea if this the right thing to do...
