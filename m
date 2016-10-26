Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C84F76B0265
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 12:07:30 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id t76so6579581qki.14
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 09:07:30 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id n82si1824132qkn.15.2016.10.26.09.07.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 09:07:29 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id x11so565759qka.0
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 09:07:29 -0700 (PDT)
Date: Wed, 26 Oct 2016 12:07:21 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC 0/8] Define coherent device memory node
Message-ID: <20161026160721.GA13638@gmail.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <20161024170902.GA5521@gmail.com>
 <87a8dtawas.fsf@linux.vnet.ibm.com>
 <20161025151637.GA6072@gmail.com>
 <87y41bcqow.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <87y41bcqow.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, bsingharora@gmail.com

On Wed, Oct 26, 2016 at 04:39:19PM +0530, Aneesh Kumar K.V wrote:
> Jerome Glisse <j.glisse@gmail.com> writes:
> 
> > On Tue, Oct 25, 2016 at 09:56:35AM +0530, Aneesh Kumar K.V wrote:
> >> Jerome Glisse <j.glisse@gmail.com> writes:
> >> 
> >> > On Mon, Oct 24, 2016 at 10:01:49AM +0530, Anshuman Khandual wrote:
> >> >
> >> I looked at the hmm-v13 w.r.t migration and I guess some form of device
> >> callback/acceleration during migration is something we should definitely
> >> have. I still haven't figured out how non addressable and coherent device
> >> memory can fit together there. I was waiting for the page cache
> >> migration support to be pushed to the repository before I start looking
> >> at this closely.
> >> 
> >
> > The page cache migration does not touch the migrate code path. My issue with
> > page cache is writeback. The only difference with existing migrate code is
> > refcount check for ZONE_DEVICE page. Everything else is the same.
> 
> What about the radix tree ? does file system migrate_page callback handle
> replacing normal page with ZONE_DEVICE page/exceptional entries ?
> 

It use the exact same existing code (from mm/migrate.c) so yes the radix tree
is updated and buffer_head are migrated.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
