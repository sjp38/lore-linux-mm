Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id D70E86B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 16:36:22 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hi6so273772567pac.0
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 13:36:22 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id j14si2269880pfk.232.2016.09.06.13.36.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Sep 2016 13:36:22 -0700 (PDT)
Subject: Re: [PATCH V3] mm: Add sysfs interface to dump each node's zonelist
 information
References: <1473140072-24137-2-git-send-email-khandual@linux.vnet.ibm.com>
 <1473150666-3875-1-git-send-email-khandual@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57CF28C5.3090006@intel.com>
Date: Tue, 6 Sep 2016 13:36:21 -0700
MIME-Version: 1.0
In-Reply-To: <1473150666-3875-1-git-send-email-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, Kees Cook <kees@outflux.net>

On 09/06/2016 01:31 AM, Anshuman Khandual wrote:
> [NODE (0)]
>         ZONELIST_FALLBACK
>         (0) (node 0) (zone DMA c00000000140c000)
>         (1) (node 1) (zone DMA c000000100000000)
>         (2) (node 2) (zone DMA c000000200000000)
>         (3) (node 3) (zone DMA c000000300000000)
>         ZONELIST_NOFALLBACK
>         (0) (node 0) (zone DMA c00000000140c000)

Don't we have some prohibition on dumping out kernel addresses like this
so that attackers can't trivially defeat kernel layout randomization?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
