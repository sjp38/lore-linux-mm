Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B96526B0006
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 15:15:19 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id n22-v6so1491727wmc.6
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 12:15:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f11-v6sor923342wre.53.2018.07.26.12.15.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Jul 2018 12:15:18 -0700 (PDT)
Date: Thu, 26 Jul 2018 21:15:16 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v3 4/5] mm/page_alloc: Move initialization of node and
 zones to an own function
Message-ID: <20180726191516.GA10288@techadventures.net>
References: <20180725220144.11531-1-osalvador@techadventures.net>
 <20180725220144.11531-5-osalvador@techadventures.net>
 <20180726081200.GY28386@dhcp22.suse.cz>
 <CAGM2rebcp=S+WN3owDWVSa3_6QqLzs=qbOFs76rhsxuepQ1ALw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2rebcp=S+WN3owDWVSa3_6QqLzs=qbOFs76rhsxuepQ1ALw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: mhocko@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, dan.j.williams@intel.com, osalvador@suse.de

On Thu, Jul 26, 2018 at 11:35:35AM -0400, Pavel Tatashin wrote:
> > OK, this looks definitely better. I will have to check that all the
> > required state is initialized properly. Considering the above
> > explanation I would simply fold the follow up patch into this one. It is
> > not so large it would get hard to review and you would make it clear why
> > the work is done.
> 
> I will review this work, once Oscar combines patches 4 & 5 as Michal suggested.

I will send a new version tomorrow with some fixups and patch4 and patch5 joined.

Thanks
-- 
Oscar Salvador
SUSE L3
