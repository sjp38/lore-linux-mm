Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 541796B0007
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 08:03:43 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o1-v6so6019844wmc.6
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 05:03:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q72-v6sor1414168wmd.9.2018.07.13.05.03.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Jul 2018 05:03:42 -0700 (PDT)
Date: Fri, 13 Jul 2018 14:03:40 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v5 4/5] mm/sparse: add new sparse_init_nid() and
 sparse_init()
Message-ID: <20180713120340.GA16552@techadventures.net>
References: <20180712203730.8703-1-pasha.tatashin@oracle.com>
 <20180712203730.8703-5-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180712203730.8703-5-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

On Thu, Jul 12, 2018 at 04:37:29PM -0400, Pavel Tatashin wrote:
> sparse_init() requires to temporary allocate two large buffers:
> usemap_map and map_map. Baoquan He has identified that these buffers are so
> large that Linux is not bootable on small memory machines, such as a kdump
> boot. The buffers are especially large when CONFIG_X86_5LEVEL is set, as
> they are scaled to the maximum physical memory size.
> 
> Baoquan provided a fix, which reduces these sizes of these buffers, but it
> is much better to get rid of them entirely.
> 
> Add a new way to initialize sparse memory: sparse_init_nid(), which only
> operates within one memory node, and thus allocates memory either in large
> contiguous block or allocates section by section. This eliminates the need
> for use of temporary buffers.
> 
> For simplified bisecting and review temporarly call sparse_init()
> new_sparse_init(), the new interface is going to be enabled as well as old
> code removed in the next patch.
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Looks good to me, and it will make the code much shorter/easier.

Reviewed-by: Oscar Salvador <osalvador@suse.de>

Thanks
-- 
Oscar Salvador
SUSE L3
