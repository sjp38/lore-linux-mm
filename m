Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B8AA76B0005
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 02:00:01 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d17-v6so17719517wmb.5
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 23:00:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b11-v6sor6298193wro.72.2018.07.09.22.59.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Jul 2018 23:00:00 -0700 (PDT)
Date: Tue, 10 Jul 2018 07:59:57 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v4 0/3] sparse_init rewrite
Message-ID: <20180710055957.GA7380@techadventures.net>
References: <20180709175312.11155-1-pasha.tatashin@oracle.com>
 <20180709142928.c8af4a1ddf80c407fe66b224@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180709142928.c8af4a1ddf80c407fe66b224@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org

On Mon, Jul 09, 2018 at 02:29:28PM -0700, Andrew Morton wrote:
> On Mon,  9 Jul 2018 13:53:09 -0400 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:
> 
> > In sparse_init() we allocate two large buffers to temporary hold usemap and
> > memmap for the whole machine. However, we can avoid doing that if we
> > changed sparse_init() to operated on per-node bases instead of doing it on
> > the whole machine beforehand.
> > 
> > As shown by Baoquan
> > http://lkml.kernel.org/r/20180628062857.29658-1-bhe@redhat.com
> > 
> > The buffers are large enough to cause machine stop to boot on small memory
> > systems.
> > 
> > These patches should be applied on top of Baoquan's work, as
> > CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER is removed in that work.
> > 
> > For the ease of review, I split this work so the first patch only adds new
> > interfaces, the second patch enables them, and removes the old ones.
> 
> This clashes pretty significantly with patches from Baoquan and Oscar:
> 
> mm-sparse-make-sparse_init_one_section-void-and-remove-check.patch
> mm-sparse-make-sparse_init_one_section-void-and-remove-check-fix.patch
> mm-sparse-make-sparse_init_one_section-void-and-remove-check-fix-2.patch

Does this patchset still clash with those patches?
If so, since those patches are already in the -mm tree, would it be better to re-base the patchset on top of that?

Thanks
-- 
Oscar Salvador
SUSE L3
