Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id D28576B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 01:28:51 -0400 (EDT)
Received: by mail-ia0-f170.google.com with SMTP id h8so1947601iaa.1
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 22:28:51 -0700 (PDT)
Message-ID: <515D0F8E.7020906@gmail.com>
Date: Thu, 04 Apr 2013 13:28:46 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 00/24] DNUMA: Runtime NUMA memory layout reconfiguration
References: <20130228024112.GA24970@negative> <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, David Hansen <dave@linux.vnet.ibm.com>

Hi Cody,
On 03/01/2013 04:44 AM, Cody P Schafer wrote:
> Some people asked me to send the email patches for this instead of just posting a git tree link
>
> For reference, this is the original message:
> 	http://lkml.org/lkml/2013/2/27/374

Could you show me your test codes?

> --
>
>   arch/x86/Kconfig                 |   1 -
>   arch/x86/include/asm/sparsemem.h |   4 +-
>   arch/x86/mm/numa.c               |  32 +++-
>   include/linux/dnuma.h            |  96 +++++++++++
>   include/linux/memlayout.h        | 111 +++++++++++++
>   include/linux/memory_hotplug.h   |   4 +
>   include/linux/mm.h               |   7 +-
>   include/linux/page-flags.h       |  18 ++
>   include/linux/rbtree.h           |  11 ++
>   init/main.c                      |   2 +
>   lib/rbtree.c                     |  40 +++++
>   mm/Kconfig                       |  44 +++++
>   mm/Makefile                      |   2 +
>   mm/dnuma.c                       | 351 +++++++++++++++++++++++++++++++++++++++
>   mm/internal.h                    |  13 +-
>   mm/memlayout-debugfs.c           | 323 +++++++++++++++++++++++++++++++++++
>   mm/memlayout-debugfs.h           |  35 ++++
>   mm/memlayout.c                   | 267 +++++++++++++++++++++++++++++
>   mm/memory_hotplug.c              |  53 +++---
>   mm/page_alloc.c                  | 112 +++++++++++--
>   20 files changed, 1486 insertions(+), 40 deletions(-)
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
