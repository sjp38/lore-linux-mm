Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3ED306B02AD
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 09:30:24 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f13-v6so3117126edr.10
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 06:30:24 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h13-v6si15123edj.421.2018.07.25.06.30.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 06:30:22 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6PDSqIa023802
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 09:30:20 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kersqwkbk-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 09:30:17 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 25 Jul 2018 14:30:14 +0100
Date: Wed, 25 Jul 2018 16:30:08 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 5/7] docs/core-api: split memory management API to a
 separate file
References: <1532517970-16409-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1532517970-16409-6-git-send-email-rppt@linux.vnet.ibm.com>
 <20180725120500.GA9352@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180725120500.GA9352@bombadil.infradead.org>
Message-Id: <20180725133007.GB25188@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 25, 2018 at 05:05:00AM -0700, Matthew Wilcox wrote:
> On Wed, Jul 25, 2018 at 02:26:08PM +0300, Mike Rapoport wrote:
> > +User Space Memory Access
> > +========================
> > +
> > +.. kernel-doc:: arch/x86/include/asm/uaccess.h
> > +   :internal:
> > +
> > +.. kernel-doc:: arch/x86/lib/usercopy_32.c
> > +   :export:
> > +
> > +The Slab Cache
> > +==============
> > +
> > +.. kernel-doc:: include/linux/slab.h
> > +   :internal:
> > +
> > +.. kernel-doc:: mm/slab.c
> > +   :export:
> > +
> > +.. kernel-doc:: mm/util.c
> > +   :functions: kfree_const kvmalloc_node kvfree get_user_pages_fast
> 
> get_user_pages_fast would fit better in the previous 'User Space Memory
> Access' section.

Yeah, it's somewhat "backward compatible" version :)

Will fix.
 
-- 
Sincerely yours,
Mike.
