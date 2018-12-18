Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id EBBB68E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 09:22:43 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id 39so4061852edq.13
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 06:22:43 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l13si714908edw.439.2018.12.18.06.22.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 06:22:42 -0800 (PST)
Date: Tue, 18 Dec 2018 15:22:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V4 0/3] * mm/kvm/vfio/ppc64: Migrate compound pages out
 of CMA region
Message-ID: <20181218142239.GL30879@dhcp22.suse.cz>
References: <20181121092259.16482-1-aneesh.kumar@linux.ibm.com>
 <20181207151226.cb00ace433738cf550e66885@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181207151226.cb00ace433738cf550e66885@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Alexey Kardashevskiy <aik@ozlabs.ru>, mpe@ellerman.id.au, paulus@samba.org, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Fri 07-12-18 15:12:26, Andrew Morton wrote:
> On Wed, 21 Nov 2018 14:52:56 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:
> 
> > Subject: [PATCH V4 0/3] * mm/kvm/vfio/ppc64: Migrate compound pages out of CMA region
> 
> Asterisk in title is strange?
> 
> > ppc64 use CMA area for the allocation of guest page table (hash page table). We won't
> > be able to start guest if we fail to allocate hash page table. We have observed
> > hash table allocation failure because we failed to migrate pages out of CMA region
> > because they were pinned. This happen when we are using VFIO. VFIO on ppc64 pins
> > the entire guest RAM. If the guest RAM pages get allocated out of CMA region, we
> > won't be able to migrate those pages. The pages are also pinned for the lifetime of the
> > guest.
> > 
> > Currently we support migration of non-compound pages. With THP and with the addition of
> >  hugetlb migration we can end up allocating compound pages from CMA region. This
> > patch series add support for migrating compound pages. The first path adds the helper
> > get_user_pages_cma_migrate() which pin the page making sure we migrate them out of
> > CMA region before incrementing the reference count. 
> 
> Very little review activity.  Perhaps Andrey and/or Michal can find the
> time..

I will unlikely find some time before the end of the year. Sorry about
that.
-- 
Michal Hocko
SUSE Labs
