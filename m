Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 06D9C6B0281
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 11:21:06 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id g1-v6so2330925edp.2
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 08:21:05 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z14-v6si1371156edq.292.2018.07.04.08.21.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 08:21:04 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w64FIhjJ034304
	for <linux-mm@kvack.org>; Wed, 4 Jul 2018 11:21:02 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k0yt8th66-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Jul 2018 11:21:02 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 4 Jul 2018 16:21:00 +0100
Date: Wed, 4 Jul 2018 18:20:54 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/memblock: replace u64 with phys_addr_t where
 appropriate
References: <1530637506-1256-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180703125722.6fd0f02b27c01f5684877354@linux-foundation.org>
 <063c785caa11b8e1c421c656b2a030d45d6eb68f.camel@perches.com>
 <20180704070305.GB4352@rapoport-lnx>
 <20180704072308.GA458@jagdpanzerIV>
 <8dc61092669356f5417bc275e3b7c69ce637e63e.camel@perches.com>
 <20180704092042.GC458@jagdpanzerIV>
 <20180704094344.GD458@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180704094344.GD458@jagdpanzerIV>
Message-Id: <20180704152053.GJ4352@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, Jul 04, 2018 at 06:43:44PM +0900, Sergey Senozhatsky wrote:
> On (07/04/18 18:20), Sergey Senozhatsky wrote:
> > > There's this saying about habits made to be broken.
> > > This is one of those habits.
> > > 
> > > I'd expect more people probably get the %pS or %ps wrong
> > > than use %pF.
> > > 
> > > And most people probably look for examples in code and
> > > copy instead of thinking what's correct, so removing old
> > > and deprecated uses from existing code is a good thing.
> > 
> > Well, I don't NACK the patch, I just want to keep pf/pF in vsprintf(),
> > that's it. Yes, checkpatch warns about pf/pF uses, becuase we don't want
> > any new pf/pF in the code - it's rather confusing to have both pf/pF and
> > ps/pS -- but I don't necessarily see why would we want to mess up with
> > parisc/hppa/ia64 people using pf/pF for debugging purposes, etc. I'm not
> > married to pf/pF, if you guys insist on complete removal of pf/pF then so
> > be it.
> 
> And just for the record - I think the reason why I didn't feel like
> doing a tree wide pf->ps conversion was that some of those pf->ps
> printk-s could end up in -stable backports [sure, no one backports
> print out changes, but a print out can be part of a fix which gets
> backported, etc]. So I just decided to stay away from this. IIRC.

Well, this is true for any printk that uses %p[sS]. There were plenty of
those even when %pf and %ps were different... 
 
> 	-ss
> 

-- 
Sincerely yours,
Mike.
