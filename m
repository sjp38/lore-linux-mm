Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 40A226B0003
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 07:16:14 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id h26-v6so7194462itj.6
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 04:16:14 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id n11-v6si17280308ioj.55.2018.07.13.04.16.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 04:16:13 -0700 (PDT)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6DB4xmS171561
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 11:16:12 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2k2p767bbm-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 11:16:12 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w6DBGBBC029406
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 11:16:11 GMT
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w6DBGBEJ021468
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 11:16:11 GMT
Received: by mail-oi0-f46.google.com with SMTP id i12-v6so61559911oik.2
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 04:16:10 -0700 (PDT)
MIME-Version: 1.0
References: <20180712203730.8703-1-pasha.tatashin@oracle.com>
 <20180712203730.8703-6-pasha.tatashin@oracle.com> <20180713090949.GA15039@techadventures.net>
In-Reply-To: <20180713090949.GA15039@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 13 Jul 2018 07:15:34 -0400
Message-ID: <CAGM2reZs_jvgCXfu7Rd6bmQiRhYZQQC18oAFxe5j0jA+Ndt2rQ@mail.gmail.com>
Subject: Re: [PATCH v5 5/5] mm/sparse: delete old sprase_init and enable new one
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, bhe@redhat.com, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

On Fri, Jul 13, 2018 at 5:09 AM Oscar Salvador
<osalvador@techadventures.net> wrote:
>
>
> > -#ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
> > -static void __init sparse_early_mem_maps_alloc_node(void *data,
> > -                              unsigned long pnum_begin,
> > -                              unsigned long pnum_end,
> > -                              unsigned long map_count, int nodeid)
> > -{
> > -     struct page **map_map = (struct page **)data;
> > -
> > -     sparse_buffer_init(section_map_size() * map_count, nodeid);
> > -     sparse_mem_maps_populate_node(map_map, pnum_begin, pnum_end,
> > -                                      map_count, nodeid);
> > -     sparse_buffer_fini();
> > -}
>
> From now on, sparse_mem_maps_populate_node() is not being used anymore, so I guess we can just
> remove it from sparse.c, right? (as it is done in sparse-vmemmap.c).

Missed this one, even more code can be deleted! :) I will include this
in updated patches, after review comments.

Thank you,
Pavel

> --
> Oscar Salvador
> SUSE L3
>
