Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id D58236B025E
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 17:12:43 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id j4so132934233uaj.2
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 14:12:43 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f75si931749ywb.114.2016.08.31.14.12.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 14:12:43 -0700 (PDT)
Date: Wed, 31 Aug 2016 14:12:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: Add sysfs interface to dump each node's
 zonelist information
Message-Id: <20160831141239.9624b38201796007c2735029@linux-foundation.org>
In-Reply-To: <1472613950-16867-2-git-send-email-khandual@linux.vnet.ibm.com>
References: <1472613950-16867-1-git-send-email-khandual@linux.vnet.ibm.com>
	<1472613950-16867-2-git-send-email-khandual@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 31 Aug 2016 08:55:50 +0530 Anshuman Khandual <khandual@linux.vnet.ibm.com> wrote:

> Each individual node in the system has a ZONELIST_FALLBACK zonelist
> and a ZONELIST_NOFALLBACK zonelist. These zonelists decide fallback
> order of zones during memory allocations. Sometimes it helps to dump
> these zonelists to see the priority order of various zones in them.
> This change just adds a sysfs interface for doing the same.
> 
> Example zonelist information from a KVM guest.
> 
> [NODE (0)]
>         ZONELIST_FALLBACK
>         (0) (node 0) (zone DMA c00000000140c000)
>         (1) (node 1) (zone DMA c000000100000000)
>         (2) (node 2) (zone DMA c000000200000000)
>         (3) (node 3) (zone DMA c000000300000000)
>         ZONELIST_NOFALLBACK
>         (0) (node 0) (zone DMA c00000000140c000)
> [NODE (1)]
>         ZONELIST_FALLBACK
>         (0) (node 1) (zone DMA c000000100000000)
>         (1) (node 2) (zone DMA c000000200000000)
>         (2) (node 3) (zone DMA c000000300000000)
>         (3) (node 0) (zone DMA c00000000140c000)
>         ZONELIST_NOFALLBACK
>         (0) (node 1) (zone DMA c000000100000000)
> [NODE (2)]
>         ZONELIST_FALLBACK
>         (0) (node 2) (zone DMA c000000200000000)
>         (1) (node 3) (zone DMA c000000300000000)
>         (2) (node 0) (zone DMA c00000000140c000)
>         (3) (node 1) (zone DMA c000000100000000)
>         ZONELIST_NOFALLBACK
>         (0) (node 2) (zone DMA c000000200000000)
> [NODE (3)]
>         ZONELIST_FALLBACK
>         (0) (node 3) (zone DMA c000000300000000)
>         (1) (node 0) (zone DMA c00000000140c000)
>         (2) (node 1) (zone DMA c000000100000000)
>         (3) (node 2) (zone DMA c000000200000000)
>         ZONELIST_NOFALLBACK
>         (0) (node 3) (zone DMA c000000300000000)

Can you please sell this a bit better?  Why does it "sometimes help"? 
Why does the benefit of this patch to our users justify the overhead
and cost?

Please document the full path to the sysfs file(s) within the changelog.

Please find somewhere in Documentation/ to document the new interface.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
