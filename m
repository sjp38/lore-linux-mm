Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9E97A8E00C8
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 03:44:40 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e17so3375950edr.7
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 00:44:40 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g51si6903961edg.7.2019.01.25.00.44.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 00:44:39 -0800 (PST)
Date: Fri, 25 Jan 2019 08:44:36 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [-next 20190118] "kernel BUG at mm/page_alloc.c:3112!"
Message-ID: <20190125084436.GA26418@suse.de>
References: <20190121154312.GH4020@osiris>
 <20190121160607.GV4087@dhcp22.suse.cz>
 <20190121163747.GL28934@suse.de>
 <20190125080307.GA3561@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190125080307.GA3561@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-next@vger.kernel.org, Michael Holzheu <holzheu@linux.ibm.com>, Vlastimil Babka <vbabka@suse.cz>

On Fri, Jan 25, 2019 at 09:03:07AM +0100, Heiko Carstens wrote:
> On Mon, Jan 21, 2019 at 04:37:47PM +0000, Mel Gorman wrote:
> > On Mon, Jan 21, 2019 at 05:06:07PM +0100, Michal Hocko wrote:
> > > This sounds familiar. Cc Mel and Vlastimil.
> > > 
> > 
> > There is a series sitting in Andrew's inbox that replaces a compaction
> > series. A patch is dropped in the new version that deals with pages
> > getting freed during compaction that *may* be allowing active pages to
> > reach the free list and not tripping a warning like it should. I'm hoping
> > it'll be picked up soon to see if this particular bug persists or if it's
> > something else.
> 
> Has this been picked up already? With linux next 20190124 I still get this:
> 

Unfortunately not. Andrew will hopefully be online next week to pick it
up.

-- 
Mel Gorman
SUSE Labs
