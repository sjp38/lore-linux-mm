Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 832826B0003
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 13:52:20 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z5-v6so1144427edr.19
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 10:52:20 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b16-v6si1608362eds.55.2018.07.26.10.52.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 10:52:19 -0700 (PDT)
Date: Thu, 26 Jul 2018 19:52:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 2/5] mm: access zone->node via zone_to_nid() and
 zone_set_nid()
Message-ID: <20180726175212.GQ28386@dhcp22.suse.cz>
References: <20180725220144.11531-1-osalvador@techadventures.net>
 <20180725220144.11531-3-osalvador@techadventures.net>
 <20180726080500.GX28386@dhcp22.suse.cz>
 <20180726081215.GC22028@techadventures.net>
 <20180726151420.uigttpoclcka6h4h@xakep.localdomain>
 <20180726164304.GP28386@dhcp22.suse.cz>
 <CAGM2reatUAekg=e9FQM1-UVLOSBKb74-FYo7FcPqO_WaR7AmOQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reatUAekg=e9FQM1-UVLOSBKb74-FYo7FcPqO_WaR7AmOQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: osalvador@techadventures.net, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, dan.j.williams@intel.com, osalvador@suse.de

On Thu 26-07-18 13:18:46, Pavel Tatashin wrote:
> > > OpenGrok was used to find places where zone->node is accessed. A public one
> > > is available here: http://src.illumos.org/source/
> >
> > I assume that tool uses some pattern matching or similar so steps to use
> > the tool to get your results would be more helpful. This is basically
> > the same thing as coccinelle generated patches.
> 
> OpenGrok is very easy to use, it is source browser, similar to cscope
> except obviously you can't edit the browsed code. I could have used
> cscope just as well here.

OK, then I misunderstood. I thought it was some kind of c aware grep
that found all the usage for you. If this is cscope like then it is not
worth mentioning in the changelog. 
-- 
Michal Hocko
SUSE Labs
