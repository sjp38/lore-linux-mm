Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B85196B735E
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 03:30:25 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id b3so9518687edi.0
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 00:30:25 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m12si1002248edc.331.2018.12.05.00.30.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 00:30:24 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB58OKrf138113
	for <linux-mm@kvack.org>; Wed, 5 Dec 2018 03:30:22 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2p6a2hkdhg-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Dec 2018 03:30:22 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 5 Dec 2018 08:30:21 -0000
Date: Wed, 5 Dec 2018 10:30:13 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH 1/2] admin-guide/memory-hotplug.rst: remove locking
 internal part from admin-guide
References: <20181205023426.24029-1-richard.weiyang@gmail.com>
 <c4f2a712-391b-60b9-64fa-bc8b6bde9994@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c4f2a712-391b-60b9-64fa-bc8b6bde9994@redhat.com>
Message-Id: <20181205083012.GA19181@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, osalvador@suse.de, akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, Mike Rapoport <rppt@linux.vnet.ibm.com>

On Wed, Dec 05, 2018 at 09:03:24AM +0100, David Hildenbrand wrote:
> On 05.12.18 03:34, Wei Yang wrote:
> > Locking Internal section exists in core-api documentation, which is more
> > suitable for this.
> > 
> > This patch removes the duplication part here.
> > 
> > Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> > ---
> >  Documentation/admin-guide/mm/memory-hotplug.rst | 40 -------------------------
> >  1 file changed, 40 deletions(-)
> > 
> > diff --git a/Documentation/admin-guide/mm/memory-hotplug.rst b/Documentation/admin-guide/mm/memory-hotplug.rst
> > index 5c4432c96c4b..241f4ce1e387 100644
> > --- a/Documentation/admin-guide/mm/memory-hotplug.rst
> > +++ b/Documentation/admin-guide/mm/memory-hotplug.rst
> > @@ -392,46 +392,6 @@ Need more implementation yet....
> >   - Notification completion of remove works by OS to firmware.
> >   - Guard from remove if not yet.

[ ... ]

> >  Future Work
> >  ===========
> >  
> > 
> 
> I reported this yesterday to Jonathan and Mike
> 
> https://lkml.org/lkml/2018/12/3/340

Somehow I've missed it...
 
> Anyhow
> 
> Reviewed-by: David Hildenbrand <david@redhat.com>

Acked-by: Mike Rapoport <rppt@linux.ibm.com>

> 
> -- 
> 
> Thanks,
> 
> David / dhildenb
> 

-- 
Sincerely yours,
Mike.
