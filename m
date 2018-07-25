Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id DCE006B02B2
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 09:51:51 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id r20-v6so4208331pgv.20
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 06:51:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 9-v6si13582437pgu.130.2018.07.25.06.51.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 06:51:50 -0700 (PDT)
Date: Wed, 25 Jul 2018 15:51:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1 0/2] mm/kdump: exclude reserved pages in dumps
Message-ID: <20180725135147.GN28386@dhcp22.suse.cz>
References: <20180720123422.10127-1-david@redhat.com>
 <9f46f0ed-e34c-73be-60ca-c892fb19ed08@suse.cz>
 <20180723123043.GD31229@dhcp22.suse.cz>
 <8daae80c-871e-49b6-1cf1-1f0886d3935d@redhat.com>
 <20180724072536.GB28386@dhcp22.suse.cz>
 <8eb22489-fa6b-9825-bc63-07867a40d59b@redhat.com>
 <20180724131343.GK28386@dhcp22.suse.cz>
 <af5353ee-319e-17ec-3a39-df997a5adf43@redhat.com>
 <20180724133530.GN28386@dhcp22.suse.cz>
 <6c753cae-f8b6-5563-e5ba-7c1fefdeb74e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6c753cae-f8b6-5563-e5ba-7c1fefdeb74e@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Dave Young <dyoung@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, =?iso-8859-1?Q?Marc-Andr=E9?= Lureau <marcandre.lureau@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Miles Chen <miles.chen@mediatek.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Petr Tesarik <ptesarik@suse.cz>

On Tue 24-07-18 16:13:09, David Hildenbrand wrote:
[...]
> So I see right now:
> 
> - Pg_reserved + e.g. new page type (or some other unique identifier in
>   combination with Pg_reserved)
>  -> Avoid reads of pages we know are offline
> - extend is_ram_page()
>  -> Fake zero memory for pages we know are offline
> 
> Or even both (avoid reading and don't crash the kernel if it is being done).

I really fail to see how that can work without kernel being aware of
PageOffline. What will/should happen if you run an old kdump tool on a
kernel with this partially offline memory?
-- 
Michal Hocko
SUSE Labs
