Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5318E0003
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 06:33:18 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w12-v6so1747343oie.12
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 03:33:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w203-v6si454067oif.130.2018.09.12.03.33.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 03:33:17 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8CAObcC069932
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 06:33:16 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mey20wrkt-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 06:33:16 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 12 Sep 2018 11:33:13 +0100
Date: Wed, 12 Sep 2018 13:33:06 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 3/3] docs: core-api: add memory allocation guide
References: <1534517236-16762-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1534517236-16762-4-git-send-email-rppt@linux.vnet.ibm.com>
 <20180911115555.5fce5631@lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180911115555.5fce5631@lwn.net>
Message-Id: <20180912103305.GC6719@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Michal Hocko <mhocko@suse.com>, Randy Dunlap <rdunlap@infradead.org>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Sep 11, 2018 at 11:55:55AM -0600, Jonathan Corbet wrote:
> Sorry for being so slow to get to this...it fell into a dark crack in my
> rickety email folder hierarchy.  I do have one question...
> 
> On Fri, 17 Aug 2018 17:47:16 +0300
> Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> 
> > +    ``GFP_HIGHUSER_MOVABLE`` does not require that allocated memory
> > +    will be directly accessible by the kernel or the hardware and
> > +    implies that the data is movable.
> > +
> > +    ``GFP_HIGHUSER`` means that the allocated memory is not movable,
> > +    but it is not required to be directly accessible by the kernel or
> > +    the hardware. An example may be a hardware allocation that maps
> > +    data directly into userspace but has no addressing limitations.
> > +
> > +    ``GFP_USER`` means that the allocated memory is not movable and it
> > +    must be directly accessible by the kernel or the hardware. It is
> > +    typically used by hardware for buffers that are mapped to
> > +    userspace (e.g. graphics) that hardware still must DMA to.
> 
> I realize that this is copied from elsewhere, but still...as I understand
> it, the "HIGH" part means that the allocation can be satisfied from high
> memory, nothing more.  So...it's irrelevant on 64-bit machines to start
> with, right?  And it has nothing to do with DMA, I would think.  That would
> be handled by the DMA infrastructure and, perhaps, the DMA* zones.  Right?
> 
> I ask because high memory is an artifact of how things are laid out on
> 32-bit systems; hardware can often DMA quite easily into memory that the
> kernel sees as "high".  So, to me, this description seems kind of
> confusing; I wouldn't mention hardware at all.  But maybe I'm missing
> something?

Well, I've amended the original text from gfp.h in attempt to make it more
"user friendly". The GFP_HIGHUSER became really confusing :)
I think that we can drop mentions of hardware from GFP_HIGHUSER_MOVABLE and
GFP_USER, but it makes sense to leave the example in the GFP_HIGHUSER
description.

How about:

    ``GFP_HIGHUSER_MOVABLE`` does not require that allocated memory
    will be directly accessible by the kernel and implies that the
    data is movable.

    ``GFP_HIGHUSER`` means that the allocated memory is not movable,
    but it is not required to be directly accessible by the kernel. An
    example may be a hardware allocation that maps data directly into
    userspace but has no addressing limitations.

    ``GFP_USER`` means that the allocated memory is not movable and it
    must be directly accessible by the kernel

 
> Thanks,
> 
> jon
> 

-- 
Sincerely yours,
Mike.
