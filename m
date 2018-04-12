Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id A5EEC6B0003
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 01:51:27 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f9-v6so2955350plo.17
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 22:51:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n2si1826508pgs.500.2018.04.11.22.51.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Apr 2018 22:51:26 -0700 (PDT)
Date: Thu, 12 Apr 2018 07:51:22 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [LSF/MM TOPIC] CMA and larger page sizes
Message-ID: <20180412055122.GP23400@dhcp22.suse.cz>
References: <3a3d724e-4d74-9bd8-60f3-f6896cffac7a@redhat.com>
 <20180126172527.GI5027@dhcp22.suse.cz>
 <20180404051115.GC6628@js1304-desktop>
 <075843db-ec6e-3822-a60c-ae7487981f09@redhat.com>
 <d88676d9-8f42-2519-56bf-776e46b1180e@suse.cz>
 <b1420dd8-23ae-89e8-3b9d-62663bd69e24@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b1420dd8-23ae-89e8-3b9d-62663bd69e24@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Wed 11-04-18 18:06:59, Laura Abbott wrote:
> On 04/11/2018 01:02 PM, Vlastimil Babka wrote:
> > On 04/11/2018 09:55 PM, Laura Abbott wrote:
> > > On 04/03/2018 10:11 PM, Joonsoo Kim wrote:
> > > > If the patchset 'manage the memory of the CMA area by using the ZONE_MOVABLE' is
> > > > merged, this restriction can be removed since there is no unmovable
> > > > pageblock in ZONE_MOVABLE. Just quick thought. :)
> > > > 
> > > > Thanks.
> > > > 
> > > 
> > > Thanks for that pointer. What's the current status of that patchset? Was that
> > > one that needed more review/testing?
> > 
> > It was merged by Linus today, see around commit bad8c6c0b114 ("mm/cma:
> > manage the memory of the CMA area by using the ZONE_MOVABLE")
> > 
> > Congrats, Joonsoo :)
> > 
> 
> I took a look at this a little bit more and while it's true we don't
> have the unmovable restriction anymore, CMA is still tied to the pageblock
> size (512MB) because we still have MIGRATE_CMA. I guess making the
> pageblock smaller seems like the most plausible approach?

Maybe I am wrong but my take on what Joonsoo said is that we really do
not have to care about page blocks and MIGRATE_CMA because GFP_MOVABLE
can be allocated from that migrate type as it is by definition movable.
The size of the page block shouldn't matter.
-- 
Michal Hocko
SUSE Labs
