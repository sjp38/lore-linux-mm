Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7BBE46B0283
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 08:36:46 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w42-v6so2720059edd.0
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 05:36:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gw15-v6si793472ejb.224.2018.10.24.05.36.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 05:36:44 -0700 (PDT)
Date: Wed, 24 Oct 2018 14:36:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [mm PATCH v3 4/6] mm: Move hot-plug specific memory init into
 separate functions and optimize
Message-ID: <20181024123640.GF18839@dhcp22.suse.cz>
References: <20181015202456.2171.88406.stgit@localhost.localdomain>
 <20181015202716.2171.7284.stgit@localhost.localdomain>
 <20181017091824.GL18839@dhcp22.suse.cz>
 <d9011108-4099-58dc-8b8c-110c5f2a3674@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d9011108-4099-58dc-8b8c-110c5f2a3674@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, pavel.tatashin@microsoft.com, dave.jiang@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, davem@davemloft.net, yi.z.zhang@linux.intel.com, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com, vbabka@suse.cz, sparclinux@vger.kernel.org, dan.j.williams@intel.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mingo@kernel.org, kirill.shutemov@linux.intel.com

On Wed 17-10-18 08:26:20, Alexander Duyck wrote:
[...]
> With that said I am also wondering if a possible solution to the complaints
> you had would be to look at just exporting the __init_pageblock function
> later and moving the call to memmap_init_zone_device out to the memremap or
> hotplug code when Dan gets the refactoring for HMM and memremap all sorted
> out.

Why cannot we simply provide a constructor for each page by the caller
if there are special requirements? we currently have alt_map to do
struct page allocation but nothing really prevents to make it more
generic and control both allocation and initialization whatever suits a
specific usecase. I really do not want make special cases here and
there.
-- 
Michal Hocko
SUSE Labs
