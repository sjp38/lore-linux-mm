Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9DB5D6B0003
	for <linux-mm@kvack.org>; Sun, 15 Apr 2018 13:29:27 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v11so10522598wri.13
        for <linux-mm@kvack.org>; Sun, 15 Apr 2018 10:29:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j2si1539796edf.459.2018.04.15.10.29.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Apr 2018 10:29:26 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3FHT07n007569
	for <linux-mm@kvack.org>; Sun, 15 Apr 2018 13:29:24 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hbyjx38wk-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 15 Apr 2018 13:29:24 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sun, 15 Apr 2018 18:29:21 +0100
Date: Sun, 15 Apr 2018 20:29:11 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/32] docs/vm: convert to ReST format
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180329154607.3d8bda75@lwn.net>
 <20180401063857.GA3357@rapoport-lnx>
 <20180413135551.0e6d1b12@lwn.net>
 <20180413202108.GA30271@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180413202108.GA30271@bombadil.infradead.org>
Message-Id: <20180415172910.GA31176@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri, Apr 13, 2018 at 01:21:08PM -0700, Matthew Wilcox wrote:
> On Fri, Apr 13, 2018 at 01:55:51PM -0600, Jonathan Corbet wrote:
> > > I believe that keeping the mm docs together will give better visibility of
> > > what (little) mm documentation we have and will make the updates easier.
> > > The documents that fit well into a certain topic could be linked there. For
> > > instance:
> > 
> > ...but this sounds like just the opposite...?  
> > 
> > I've had this conversation with folks in a number of subsystems.
> > Everybody wants to keep their documentation together in one place - it's
> > easier for the developers after all.  But for the readers I think it's
> > objectively worse.  It perpetuates the mess that Documentation/ is, and
> > forces readers to go digging through all kinds of inappropriate material
> > in the hope of finding something that tells them what they need to know.
> > 
> > So I would *really* like to split the documentation by audience, as has
> > been done for a number of other kernel subsystems (and eventually all, I
> > hope).
> > 
> > I can go ahead and apply the RST conversion, that seems like a step in
> > the right direction regardless.  But I sure hope we don't really have to
> > keep it as an unorganized jumble of stuff...
> 
> I've started on Documentation/core-api/memory.rst which covers just
> memory allocation.  So far it has the Overview and GFP flags sections
> written and an outline for 'The slab allocator', 'The page allocator',
> 'The vmalloc allocator' and 'The page_frag allocator'.  And typing this
> up, I realise we need a 'The percpu allocator'.  I'm thinking that this
> is *not* the right document for the DMA memory allocators (although it
> should link to that documentation).
> 
> I suspect the existing Documentation/vm/ should probably stay as an
> unorganised jumble of stuff.  Developers mostly talking to other MM
> developers.  Stuff that people outside the MM fraternity should know
> about needs to be centrally documented.  By all means convert it to
> ReST ... I don't much care, and it may make it easier to steal bits
> or link to it from the organised documentation.
 
The existing Documentation/vm contains different types of documents. Some
are indeed "Developers mostly talking to other MM developers". Some are
really user/administrator guides. Others are somewhat in between.

I took another look at what's there and I think we can actually move part
of Documentation/vm to Documentation/admin-guide. We can add
Documentation/admin-guide/vm/ and title it "Memory Management Tuning" or
something like that. And several files, e.g. hugetlbpage, ksm, soft-dirty
can be moved there.

-- 
Sincerely yours,
Mike.
