Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2F1B36B0003
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 11:26:50 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id y7-v6so8234403plt.17
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 08:26:50 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id cc1-v6si14344838plb.458.2018.07.01.08.26.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 01 Jul 2018 08:26:48 -0700 (PDT)
Subject: Re: [PATCH v2 00/11] docs/mm: add boot time memory management docs
References: <1530370506-21751-1-git-send-email-rppt@linux.vnet.ibm.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <6c4dbd5e-a7c9-06de-5c9f-1c311b782244@infradead.org>
Date: Sun, 1 Jul 2018 08:26:46 -0700
MIME-Version: 1.0
In-Reply-To: <1530370506-21751-1-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>
Cc: linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On 06/30/18 07:54, Mike Rapoport wrote:
> Hi,
> 
> Both bootmem and memblock have pretty good documentation coverage. With
> some fixups and additions we get a nice overall description.
> 
> v2 changes:
> * address Randy's comments

For the series:
Acked-by: Randy Dunlap <rdunlap@infradead.org>

Thanks.


> Mike Rapoport (11):
>   mm/bootmem: drop duplicated kernel-doc comments
>   docs/mm: nobootmem: fixup kernel-doc comments
>   docs/mm: bootmem: fix kernel-doc warnings
>   docs/mm: bootmem: add kernel-doc description of 'struct bootmem_data'
>   docs/mm: bootmem: add overview documentation
>   mm/memblock: add a name for memblock flags enumeration
>   docs/mm: memblock: update kernel-doc comments
>   docs/mm: memblock: add kernel-doc comments for memblock_add[_node]
>   docs/mm: memblock: add kernel-doc description for memblock types
>   docs/mm: memblock: add overview documentation
>   docs/mm: add description of boot time memory management
> 
>  Documentation/core-api/boot-time-mm.rst |  92 +++++++++++++++
>  Documentation/core-api/index.rst        |   1 +
>  include/linux/bootmem.h                 |  17 ++-
>  include/linux/memblock.h                |  76 ++++++++----
>  mm/bootmem.c                            | 159 +++++++++----------------
>  mm/memblock.c                           | 203 +++++++++++++++++++++++---------
>  mm/nobootmem.c                          |  20 +++-
>  7 files changed, 380 insertions(+), 188 deletions(-)
>  create mode 100644 Documentation/core-api/boot-time-mm.rst
> 


-- 
~Randy
