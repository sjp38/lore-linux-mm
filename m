Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 139C76B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 14:21:50 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id i8-v6so2311644plt.8
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:21:50 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o128si9899922pga.653.2018.04.16.11.21.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 16 Apr 2018 11:21:49 -0700 (PDT)
Date: Mon, 16 Apr 2018 11:21:46 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] dax: Change return type to vm_fault_t
Message-ID: <20180416182146.GC12686@bombadil.infradead.org>
References: <20180414155059.GA18015@jordon-HP-15-Notebook-PC>
 <CAPcyv4g+Gdc2tJ1qrM5Xn9vtARw-ZqFXaMbiaBKJJsYDtSNBig@mail.gmail.com>
 <20180416174740.GA12686@bombadil.infradead.org>
 <CAPcyv4hUsADs9ueDfLKvcqHvz3Z4ziW=a1V6rkcOtTvoJhw7xg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hUsADs9ueDfLKvcqHvz3Z4ziW=a1V6rkcOtTvoJhw7xg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

On Mon, Apr 16, 2018 at 11:00:26AM -0700, Dan Williams wrote:
> On Mon, Apr 16, 2018 at 10:47 AM, Matthew Wilcox <willy@infradead.org> wrote:
> > On Mon, Apr 16, 2018 at 09:14:48AM -0700, Dan Williams wrote:
> >> > -       rc = vm_insert_mixed(vmf->vma, vmf->address, pfn);
> >> > -
> >> > -       if (rc == -ENOMEM)
> >> > -               return VM_FAULT_OOM;
> >> > -       if (rc < 0 && rc != -EBUSY)
> >> > -               return VM_FAULT_SIGBUS;
> >> > -
> >> > -       return VM_FAULT_NOPAGE;
> >> > +       return vmf_insert_mixed(vmf->vma, vmf->address, pfn);
> >>
> >> Ugh, so this change to vmf_insert_mixed() went upstream without fixing
> >> the users? This changelog is now misleading as it does not mention
> >> that is now an urgent standalone fix. On first read I assumed this was
> >> part of a wider effort for 4.18.
> >
> > You read too quickly.  vmf_insert_mixed() is a *new* function which
> > *replaces* vm_insert_mixed() and
> > awful-mangling-of-return-values-done-per-driver.
> >
> > Eventually vm_insert_mixed() will be deleted.  But today is not that day.
> 
> Ah, ok, thanks for the clarification. Then this patch should
> definitely be re-titled to "dax: convert to the new vmf_insert_mixed()
> helper". The vm_fault_t conversion is just a minor side-effect of that
> larger change. I assume this can wait for v4.18.

Yes, no particular hurry.
