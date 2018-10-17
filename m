Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id BADA26B026E
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 05:33:34 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id w17-v6so21135611wrt.0
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 02:33:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 6-v6sor881920wmy.21.2018.10.17.02.33.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Oct 2018 02:33:33 -0700 (PDT)
Date: Wed, 17 Oct 2018 11:33:31 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH 2/5] mm/memory_hotplug: Create add/del_device_memory
 functions
Message-ID: <20181017093331.GA25724@techadventures.net>
References: <20181015153034.32203-1-osalvador@techadventures.net>
 <20181015153034.32203-3-osalvador@techadventures.net>
 <d0a12eb5-3824-8d25-75f8-3e62f1e81994@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d0a12eb5-3824-8d25-75f8-3e62f1e81994@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, yasu.isimatu@gmail.com, rppt@linux.vnet.ibm.com, malat@debian.org, linux-kernel@vger.kernel.org, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, dave.jiang@intel.com, linux-mm@kvack.org, alexander.h.duyck@linux.intel.com, Oscar Salvador <osalvador@suse.de>

> >  	/*
> >  	 * For device private memory we call add_pages() as we only need to
> >  	 * allocate and initialize struct page for the device memory. More-
> > @@ -1096,20 +1100,17 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
> >  	 * want the linear mapping and thus use arch_add_memory().
> >  	 */
> 
> Some parts of this comment should be moved into add_device_memory now.
> (e.g. we call add_pages() ...)

I agree.

> > +#ifdef CONFIG_ZONE_DEVICE
> > +int del_device_memory(int nid, unsigned long start, unsigned long size,
> > +				struct vmem_altmap *altmap, bool mapping)
> > +{
> > +	int ret;
> 
> nit: personally I prefer short parameters last in the list.

I do not have a strong opinion here.
If people think that long parameters should be placed at the end because
it improves readability, I am ok with moving them there.
 
> Can you document for both functions that they should be called with the
> memory hotplug lock in write?

Sure, I will do that in the next version, once I get some more feedback.

> Apart from that looks good to me.

Thanks for reviewing it David ;-)!
May I assume your Reviewed-by here (if the above comments are addressed)?

Thanks
-- 
Oscar Salvador
SUSE L3
