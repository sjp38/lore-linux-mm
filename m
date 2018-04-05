Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 53B7E6B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 18:08:45 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id o2-v6so18399572plk.14
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 15:08:45 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s10si6088354pgc.129.2018.04.05.15.08.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 15:08:44 -0700 (PDT)
Date: Thu, 5 Apr 2018 15:08:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 0/4] mm/sparse: Optimize memmap allocation during
 sparse_init()
Message-Id: <20180405150842.350e4febc06a813138f00416@linux-foundation.org>
In-Reply-To: <20180228032657.32385-1-bhe@redhat.com>
References: <20180228032657.32385-1-bhe@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, dave.hansen@intel.com, pagupta@redhat.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On Wed, 28 Feb 2018 11:26:53 +0800 Baoquan He <bhe@redhat.com> wrote:

> This is v3 post. V1 can be found here:
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

This patchset could do with some more review, please?
