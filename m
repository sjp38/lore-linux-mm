Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 71C578E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 07:20:43 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id w44-v6so2918253edb.16
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 04:20:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l4si585406edw.439.2018.09.27.04.20.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 04:20:42 -0700 (PDT)
Date: Thu, 27 Sep 2018 13:20:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Message-ID: <20180927112041.GG6278@dhcp22.suse.cz>
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925202053.3576.66039.stgit@localhost.localdomain>
 <20180926075540.GD6278@dhcp22.suse.cz>
 <6f87a5d7-05e2-00f4-8568-bb3521869cea@linux.intel.com>
 <CAPcyv4iVnodai0bB74yeSCD2H+hoLsZYUk4sR9jV0pPAE+Zorw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iVnodai0bB74yeSCD2H+hoLsZYUk4sR9jV0pPAE+Zorw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: alexander.h.duyck@linux.intel.com, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Pasha Tatashin <pavel.tatashin@microsoft.com>, Dave Jiang <dave.jiang@intel.com>, Dave Hansen <dave.hansen@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, rppt@linux.vnet.ibm.com, Logan Gunthorpe <logang@deltatee.com>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed 26-09-18 11:52:56, Dan Williams wrote:
[...]
> Could we push the hotplug lock deeper to the places that actually need
> it? What I found with my initial investigation is that we don't even
> need the hotplug lock for the vmemmap initialization with this patch
> [1].

Yes, the scope of the hotplug lock should be evaluated and _documented_.
Then we can build on top.
-- 
Michal Hocko
SUSE Labs
