Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F2A86B0008
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 15:15:59 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id f13-v6so1646032wru.5
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 12:15:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k15-v6sor928004wrm.34.2018.07.26.12.15.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Jul 2018 12:15:57 -0700 (PDT)
Date: Thu, 26 Jul 2018 21:15:56 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v3 2/5] mm: access zone->node via zone_to_nid() and
 zone_set_nid()
Message-ID: <20180726191556.GB10288@techadventures.net>
References: <20180725220144.11531-1-osalvador@techadventures.net>
 <20180725220144.11531-3-osalvador@techadventures.net>
 <20180726080500.GX28386@dhcp22.suse.cz>
 <20180726081215.GC22028@techadventures.net>
 <20180726151420.uigttpoclcka6h4h@xakep.localdomain>
 <20180726164304.GP28386@dhcp22.suse.cz>
 <CAGM2reatUAekg=e9FQM1-UVLOSBKb74-FYo7FcPqO_WaR7AmOQ@mail.gmail.com>
 <20180726175212.GQ28386@dhcp22.suse.cz>
 <CAGM2reY2HAo3UDzw=P8ue0jJmRRZou-osyJwWjXt6vtC+CF8Ug@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reY2HAo3UDzw=P8ue0jJmRRZou-osyJwWjXt6vtC+CF8Ug@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: mhocko@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, dan.j.williams@intel.com, osalvador@suse.de

On Thu, Jul 26, 2018 at 01:55:34PM -0400, Pavel Tatashin wrote:
> On Thu, Jul 26, 2018 at 1:52 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Thu 26-07-18 13:18:46, Pavel Tatashin wrote:
> > > > > OpenGrok was used to find places where zone->node is accessed. A public one
> > > > > is available here: http://src.illumos.org/source/
> > > >
> > > > I assume that tool uses some pattern matching or similar so steps to use
> > > > the tool to get your results would be more helpful. This is basically
> > > > the same thing as coccinelle generated patches.
> > >
> > > OpenGrok is very easy to use, it is source browser, similar to cscope
> > > except obviously you can't edit the browsed code. I could have used
> > > cscope just as well here.
> >
> > OK, then I misunderstood. I thought it was some kind of c aware grep
> > that found all the usage for you. If this is cscope like then it is not
> > worth mentioning in the changelog.
> 
> That's what I thought :) Oscar, will you remove the comment about
> opengrok, or should I paste a new patch?

No worries, I will remove the comment ;-).

Thanks
-- 
Oscar Salvador
SUSE L3
