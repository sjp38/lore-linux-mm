Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 047DF6B0003
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 03:22:41 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b9-v6so1286005edn.18
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 00:22:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a12-v6si5053587edm.339.2018.07.24.00.22.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 00:22:39 -0700 (PDT)
Date: Tue, 24 Jul 2018 09:22:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1 0/2] mm/kdump: exclude reserved pages in dumps
Message-ID: <20180724072237.GA28386@dhcp22.suse.cz>
References: <20180720123422.10127-1-david@redhat.com>
 <9f46f0ed-e34c-73be-60ca-c892fb19ed08@suse.cz>
 <f8d7b5f9-e5ee-0625-f53d-50d1841e1388@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f8d7b5f9-e5ee-0625-f53d-50d1841e1388@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Dave Young <dyoung@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, =?iso-8859-1?Q?Marc-Andr=E9?= Lureau <marcandre.lureau@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Miles Chen <miles.chen@mediatek.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Petr Tesarik <ptesarik@suse.cz>

On Mon 23-07-18 19:12:58, David Hildenbrand wrote:
> On 23.07.2018 13:45, Vlastimil Babka wrote:
> > On 07/20/2018 02:34 PM, David Hildenbrand wrote:
> >> Dumping tools (like makedumpfile) right now don't exclude reserved pages.
> >> So reserved pages might be access by dump tools although nobody except
> >> the owner should touch them.
> > 
> > Are you sure about that? Or maybe I understand wrong. Maybe it changed
> > recently, but IIRC pages that are backing memmap (struct pages) are also
> > PG_reserved. And you definitely do want those in the dump.
> 
> I proposed a new flag/value to mask pages that are logically offline but
> Michal wanted me to go into this direction.
> 
> While we can special case struct pages in dump tools ("we have to
> read/interpret them either way, so we can also dump them"), it smells
> like my original attempt was cleaner. Michal?

But we do not have many page flags spare and even if we have one or two
this doesn't look like the use for them. So I still think we should try
the PageReserved way.

-- 
Michal Hocko
SUSE Labs
