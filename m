Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 054E56B0003
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 02:27:40 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id n33-v6so11081141qte.23
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 23:27:40 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p128-v6si11004059qka.266.2018.06.07.23.27.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 23:27:38 -0700 (PDT)
Date: Fri, 8 Jun 2018 14:27:33 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH v4 3/4] mm/sparse: Add a new parameter 'data_unit_size'
 for alloc_usemap_and_memmap
Message-ID: <20180608062733.GB16231@MiWiFi-R3L-srv>
References: <20180521101555.25610-1-bhe@redhat.com>
 <20180521101555.25610-4-bhe@redhat.com>
 <8ff7638c-d3ee-a40c-e5cf-deded8d19e93@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8ff7638c-d3ee-a40c-e5cf-deded8d19e93@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, pagupta@redhat.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On 06/07/18 at 03:48pm, Dave Hansen wrote:
> On 05/21/2018 03:15 AM, Baoquan He wrote:
> > It's used to pass the size of map data unit into alloc_usemap_and_memmap,
> > and is preparation for next patch.
> 
> This is the "what", but not the "why".  Could you add another sentence
> or two to explain why we need this?

Thanks for reviewing, Dave.

In alloc_usemap_and_memmap(), it will call
sparse_early_usemaps_alloc_node() or sparse_early_mem_maps_alloc_node()
to allocate usemap and memmap for each node and install them into
usemap_map[] and map_map[]. Here we need pass in the number of present
sections on this node so that we can move pointer of usemap_map[] and
map_map[] to right position.

How do think about above words?

Thanks
Baoquan
