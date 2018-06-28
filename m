Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4E0E46B0007
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 09:08:08 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x6-v6so2995395wrl.6
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 06:08:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e16-v6sor732434wrr.35.2018.06.28.06.08.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Jun 2018 06:08:06 -0700 (PDT)
Date: Thu, 28 Jun 2018 15:08:04 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v6 3/5] mm/sparse: Add a new parameter 'data_unit_size'
 for alloc_usemap_and_memmap
Message-ID: <20180628130804.GA13985@techadventures.net>
References: <20180628062857.29658-1-bhe@redhat.com>
 <20180628062857.29658-4-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180628062857.29658-4-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dave.hansen@intel.com, pagupta@redhat.com, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On Thu, Jun 28, 2018 at 02:28:55PM +0800, Baoquan He wrote:
> alloc_usemap_and_memmap() is passing in a "void *" that points to
> usemap_map or memmap_map. In next patch we will change both of the
> map allocation from taking 'NR_MEM_SECTIONS' as the length to taking
> 'nr_present_sections' as the length. After that, the passed in 'void*'
> needs to update as things get consumed. But, it knows only the
> quantity of objects consumed and not the type.  This effectively
> tells it enough about the type to let it update the pointer as
> objects are consumed.
> 
> Signed-off-by: Baoquan He <bhe@redhat.com>
> Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3
