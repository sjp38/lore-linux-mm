Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6EAD88E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 18:12:30 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id s71so4575091pfi.22
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 15:12:30 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y6si3991059pgb.516.2018.12.07.15.12.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 15:12:29 -0800 (PST)
Date: Fri, 7 Dec 2018 15:12:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V4 0/3] * mm/kvm/vfio/ppc64: Migrate compound pages out
 of CMA region
Message-Id: <20181207151226.cb00ace433738cf550e66885@linux-foundation.org>
In-Reply-To: <20181121092259.16482-1-aneesh.kumar@linux.ibm.com>
References: <20181121092259.16482-1-aneesh.kumar@linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, mpe@ellerman.id.au, paulus@samba.org, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Wed, 21 Nov 2018 14:52:56 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:

> Subject: [PATCH V4 0/3] * mm/kvm/vfio/ppc64: Migrate compound pages out of CMA region

Asterisk in title is strange?

> ppc64 use CMA area for the allocation of guest page table (hash page table). We won't
> be able to start guest if we fail to allocate hash page table. We have observed
> hash table allocation failure because we failed to migrate pages out of CMA region
> because they were pinned. This happen when we are using VFIO. VFIO on ppc64 pins
> the entire guest RAM. If the guest RAM pages get allocated out of CMA region, we
> won't be able to migrate those pages. The pages are also pinned for the lifetime of the
> guest.
> 
> Currently we support migration of non-compound pages. With THP and with the addition of
>  hugetlb migration we can end up allocating compound pages from CMA region. This
> patch series add support for migrating compound pages. The first path adds the helper
> get_user_pages_cma_migrate() which pin the page making sure we migrate them out of
> CMA region before incrementing the reference count. 

Very little review activity.  Perhaps Andrey and/or Michal can find the
time..

> mm/migrate.c            | 108 ++++++++++++++++++++++++++++++++++++++++

can we make this code disappear when CONFIG_CMA=n?
