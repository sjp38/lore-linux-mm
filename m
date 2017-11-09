Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 231CA440460
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 02:57:14 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id 72so8145857itl.1
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 23:57:14 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h71si4131294pge.146.2017.11.08.23.57.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 23:57:13 -0800 (PST)
Date: Thu, 9 Nov 2017 08:57:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: page_ext: check if page_ext is not prepared
Message-ID: <20171109075709.b4umhipfg3n33qs7@dhcp22.suse.cz>
References: <CGME20171107093947epcas2p3d449dd14d11907cd29df7be7984d90f0@epcas2p3.samsung.com>
 <20171107094131.14621-1-jaewon31.kim@samsung.com>
 <20171107094730.5732nqqltx2miszq@dhcp22.suse.cz>
 <20171108075956.GC18747@js1304-P5Q-DELUXE>
 <20171108142106.v76ictdykeqjzhhh@dhcp22.suse.cz>
 <20171109043552.GC24383@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171109043552.GC24383@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jaewon Kim <jaewon31.kim@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, vbabka@suse.cz, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com

Andrew,

On Thu 09-11-17 13:35:53, Joonsoo Kim wrote:
> On Wed, Nov 08, 2017 at 03:21:06PM +0100, Michal Hocko wrote:
> > On Wed 08-11-17 16:59:56, Joonsoo Kim wrote:
> > > On Tue, Nov 07, 2017 at 10:47:30AM +0100, Michal Hocko wrote:
[...]
> > > > I suspec this goes all the way down to when page_ext has been
> > > > resurrected.  It is quite interesting that nobody has noticed this in 3
> > > > years but maybe the feature is not used all that much and the HW has to
> > > > be quite special to trigger. Anyway the following should be added
> > > > 
> > > >  Fixes: eefa864b701d ("mm/page_ext: resurrect struct page extending code for debugging")
> > > >  Cc: stable
> > > 
> > > IIRC, caller of lookup_page_ext() doesn't check 'NULL' until
> > > f86e427197 ("mm: check the return value of lookup_page_ext for all
> > > call sites"). So, this problem would happen old kernel even if this
> > > patch is applied to old kernel.
> > 
> > OK, then the changelog should mention dependency on that check so that
> > anybody who backports this patch to pre 4.7 kernels knows to pull that
> > one as well.
> > 
> > > IMO, proper fix is to check all the pfn in the section. It is sent
> > > from Jaewon in other mail.
> > 
> > I believe that this patch is valuable on its own and the other one
> > should build on top of it.
> 
> Okay, agreed.

could you add a note that stable backporters need to consider
f86e427197. Something like

 Cc: stable # depends on f86e427197

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
