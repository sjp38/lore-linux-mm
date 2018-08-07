Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id A0AA66B0266
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 11:03:33 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 90-v6so10749569pla.18
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 08:03:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r22-v6sor353185pgo.194.2018.08.07.08.03.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Aug 2018 08:03:32 -0700 (PDT)
Date: Tue, 7 Aug 2018 08:03:16 -0700
From: Dennis Zhou <dennisszhou@gmail.com>
Subject: Re: [PATCH] proc: add percpu populated pages count to meminfo
Message-ID: <20180807150315.GA59704@dennisz-mbp.dhcp.thefacebook.com>
References: <20180807005607.53950-1-dennisszhou@gmail.com>
 <3b792413-184b-20b1-9d90-9e69f0df8cc4@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3b792413-184b-20b1-9d90-9e69f0df8cc4@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Roman Gushchin <guro@fb.com>, kernel-team@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

Hi Vlastimil,

On Tue, Aug 07, 2018 at 03:18:31PM +0200, Vlastimil Babka wrote:
> 
> Documentation/filesystems/proc.txt should be updated as well
> 

Will do.

> >  
> > +/*
> > + * The number of populated pages in use by the allocator, protected by
> > + * pcpu_lock.  This number is kept per a unit per chunk (i.e. when a page gets
> > + * allocated/deallocated, it is allocated/deallocated in all units of a chunk
> > + * and increments/decrements this count by 1).
> > + */
> > +static int pcpu_nr_populated;
> 
> It better be unsigned long, to match others.
> 

Yeah that makes sense. I've changed this for v2.

> > +/*
> > + * pcpu_nr_populated_pages - calculate total number of populated backing pages
> > + *
> > + * This reflects the number of pages populated to back the chunks.
> > + * Metadata is excluded in the number exposed in meminfo as the number of
> > + * backing pages scales with the number of cpus and can quickly outweigh the
> > + * memory used for metadata.  It also keeps this calculation nice and simple.
> > + *
> > + * RETURNS:
> > + * Total number of populated backing pages in use by the allocator.
> > + */
> > +int pcpu_nr_populated_pages(void)
> 
> Also unsigned long please.
> 

Changed for v2.

Thanks,
Dennis
