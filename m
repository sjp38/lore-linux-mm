Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EC6C06B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 18:17:19 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y8-v6so5109747pfl.17
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 15:17:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 33-v6si53943069plo.505.2018.06.07.15.17.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 15:17:18 -0700 (PDT)
Date: Thu, 7 Jun 2018 15:17:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 0/4] mm/sparse: Optimize memmap allocation during
 sparse_init()
Message-Id: <20180607151717.618eea26c03c124c79ad50d0@linux-foundation.org>
In-Reply-To: <20180521101555.25610-1-bhe@redhat.com>
References: <20180521101555.25610-1-bhe@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, dave.hansen@intel.com, pagupta@redhat.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On Mon, 21 May 2018 18:15:51 +0800 Baoquan He <bhe@redhat.com> wrote:

> This is v4 post. V3 can be found here:
> https://lkml.org/lkml/2018/2/27/928
> 
> V1 can be found here:
> https://www.spinics.net/lists/linux-mm/msg144486.html
> 
> In sparse_init(), two temporary pointer arrays, usemap_map and map_map
> are allocated with the size of NR_MEM_SECTIONS. They are used to store
> each memory section's usemap and mem map if marked as present. In
> 5-level paging mode, this will cost 512M memory though they will be
> released at the end of sparse_init(). System with few memory, like
> kdump kernel which usually only has about 256M, will fail to boot
> because of allocation failure if CONFIG_X86_5LEVEL=y.
> 
> In this patchset, optimize the memmap allocation code to only use
> usemap_map and map_map with the size of nr_present_sections. This
> makes kdump kernel boot up with normal crashkernel='' setting when
> CONFIG_X86_5LEVEL=y.

We're still a bit short on review input for this series.  Hi, Dave!
