Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3D8DD6B4DA3
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 16:50:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r14-v6so3488847wmh.0
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 13:50:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y33-v6sor2597060wrd.44.2018.08.29.13.50.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Aug 2018 13:50:29 -0700 (PDT)
Date: Wed, 29 Aug 2018 22:50:28 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v4 0/4] Refactoring for
 remove_memory_section/unregister_mem_sect_under_nodes
Message-ID: <20180829205028.GA25072@techadventures.net>
References: <20180817090017.17610-1-osalvador@techadventures.net>
 <20180821162122.GA10300@techadventures.net>
 <20180821134318.f743b6c58f2b5a91e17e596e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180821134318.f743b6c58f2b5a91e17e596e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@suse.com, vbabka@suse.cz, dan.j.williams@intel.com, yasu.isimatu@gmail.com, jonathan.cameron@huawei.com, david@redhat.com, Pavel.Tatashin@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Tue, Aug 21, 2018 at 01:43:18PM -0700, Andrew Morton wrote:
> On Tue, 21 Aug 2018 18:21:22 +0200 Oscar Salvador <osalvador@techadventures.net> wrote:
> 
> > On Fri, Aug 17, 2018 at 11:00:13AM +0200, Oscar Salvador wrote:
> > > From: Oscar Salvador <osalvador@suse.de>
> > > 
> > > v3 -> v4:
> > >         - Make nodemask_t a stack variable
> > >         - Added Reviewed-by from David and Pavel
> > > 
> > > v2 -> v3:
> > >         - NODEMASK_FREE can deal with NULL pointers, so do not
> > >           make it conditional (by David).
> > >         - Split up node_online's check patch (David's suggestion)
> > >         - Added Reviewed-by from Andrew and David
> > >         - Fix checkpath.pl warnings
> > 
> > Andrew, will you pick up this patchset?
> > I saw that v3 was removed from the -mm tree because it was about
> > to be updated with a new version (this one), but I am not sure if
> > anything wrong happened.
> 
> Yes, things are still changing and we're late in the merge window.  I
> decided to park it and shall take it up again after 4.19-rc1.

Hi Andrew,

I just got the Reviewed-by from Pavel for patch3.
So you may consider it for -mm when you got some time.

Thanks
-- 
Oscar Salvador
SUSE L3
