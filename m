Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E197C6B0005
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 21:26:31 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id y184-v6so4410311qka.18
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 18:26:31 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d55-v6si9680245qtf.205.2018.06.05.18.26.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jun 2018 18:26:29 -0700 (PDT)
Date: Wed, 6 Jun 2018 09:26:24 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH] slab: Clean up the code comment in slab kmem_cache struct
Message-ID: <20180606012624.GA19425@MiWiFi-R3L-srv>
References: <20180603032402.27526-1-bhe@redhat.com>
 <01000163d0e8083c-096b06d6-7202-4ce2-b41c-0f33784afcda-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000163d0e8083c-096b06d6-7202-4ce2-b41c-0f33784afcda-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org

On 06/05/18 at 05:04pm, Christopher Lameter wrote:
> On Sun, 3 Jun 2018, Baoquan He wrote:
> 
> > diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
> > index d9228e4d0320..3485c58cfd1c 100644
> > --- a/include/linux/slab_def.h
> > +++ b/include/linux/slab_def.h
> > @@ -67,9 +67,10 @@ struct kmem_cache {
> >
> >  	/*
> >  	 * If debugging is enabled, then the allocator can add additional
> > -	 * fields and/or padding to every object. size contains the total
> > -	 * object size including these internal fields, the following two
> > -	 * variables contain the offset to the user object and its size.
> > +	 * fields and/or padding to every object. 'size' contains the total
> > +	 * object size including these internal fields, while 'obj_offset'
> > +	 * and 'object_size' contain the offset to the user object and its
> > +	 * size.
> >  	 */
> >  	int obj_offset;
> >  #endif /* CONFIG_DEBUG_SLAB */
> >
> 
> Wish we had some more consistent naming. object_size and obj_offset??? And
> the fields better be as close together as possible.

I am back porting Thomas's sl[a|u]b freelist randomization feature to
our distros, need go through slab code for better understanding. From
git log history, they were 'obj_offset' and 'obj_size'. Later on
'obj_size' was renamed to 'object_size' in commit 3b0efdfa1e("mm, sl[aou]b:
Extract common fields from struct kmem_cache") which is from your patch.
With my understanding, I guess you changed that on purpose because
object_size is size of each object, obj_offset is for the whole cache,
representing the offset the real object starts to be stored. And putting
them separately is for better desribing them in code comment and
distinction, e.g 'object_size' is in "4) cache creation/removal",
while 'obj_offset' is put alone to indicate it's for the whole.
