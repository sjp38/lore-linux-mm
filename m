Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 491346B1BBF
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 12:41:51 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id v27-v6so1784730ljv.1
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 09:41:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m15sor8155490lfh.52.2018.11.19.09.41.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 09:41:49 -0800 (PST)
MIME-Version: 1.0
References: <20181115154530.GA27872@jordon-HP-15-Notebook-PC>
 <20181116182836.GB17088@rapoport-lnx> <CAFqt6zYp0j999WXw9Jus0oZMjADQQkPfso8btv6du6L9CE3PXA@mail.gmail.com>
 <20181117143742.GB7861@bombadil.infradead.org> <CAFqt6zbOWX5LUTWwoGDJsGdf+pTR6N1yTPVxyr1W3-6Fte39ww@mail.gmail.com>
 <20181119162623.GA13200@rapoport-lnx>
In-Reply-To: <20181119162623.GA13200@rapoport-lnx>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Mon, 19 Nov 2018 23:15:15 +0530
Message-ID: <CAFqt6zbhodAGQz-RCB3C-wt_Mvb9QDmQ8pFeP2EO+ba2k2OccA@mail.gmail.com>
Subject: Re: [PATCH 1/9] mm: Introduce new vm_insert_range API
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.ibm.com
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, Rik van Riel <riel@surriel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com, Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, treding@nvidia.com, Kees Cook <keescook@chromium.org>, Marek Szyprowski <m.szyprowski@samsung.com>, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org, pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org, iommu@lists.linux-foundation.org, linux-media@vger.kernel.org

On Mon, Nov 19, 2018 at 9:56 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> On Mon, Nov 19, 2018 at 08:43:09PM +0530, Souptick Joarder wrote:
> > Hi Mike,
> >
> > On Sat, Nov 17, 2018 at 8:07 PM Matthew Wilcox <willy@infradead.org> wrote:
> > >
> > > On Sat, Nov 17, 2018 at 12:26:38PM +0530, Souptick Joarder wrote:
> > > > On Fri, Nov 16, 2018 at 11:59 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> > > > > > + * vm_insert_range - insert range of kernel pages into user vma
> > > > > > + * @vma: user vma to map to
> > > > > > + * @addr: target user address of this page
> > > > > > + * @pages: pointer to array of source kernel pages
> > > > > > + * @page_count: no. of pages need to insert into user vma
> > > > > > + *
> > > > > > + * This allows drivers to insert range of kernel pages they've allocated
> > > > > > + * into a user vma. This is a generic function which drivers can use
> > > > > > + * rather than using their own way of mapping range of kernel pages into
> > > > > > + * user vma.
> > > > >
> > > > > Please add the return value and context descriptions.
> > > > >
> > > >
> > > > Sure I will wait for some time to get additional review comments and
> > > > add all of those requested changes in v2.
> > >
> > > You could send your proposed wording now which might remove the need
> > > for a v3 if we end up arguing about the wording.
> >
> > Does this description looks good ?
> >
> > /**
> >  * vm_insert_range - insert range of kernel pages into user vma
> >  * @vma: user vma to map to
> >  * @addr: target user address of this page
> >  * @pages: pointer to array of source kernel pages
> >  * @page_count: number of pages need to insert into user vma
> >  *
> >  * This allows drivers to insert range of kernel pages they've allocated
> >  * into a user vma. This is a generic function which drivers can use
> >  * rather than using their own way of mapping range of kernel pages into
> >  * user vma.
> >  *
> >  * Context - Process context. Called by mmap handlers.
>
> Context:
>
> >  * Return - int error value
>
> Return:
>
> >  * 0                    - OK
> >  * -EINVAL              - Invalid argument
> >  * -ENOMEM              - No memory
> >  * -EFAULT              - Bad address
> >  * -EBUSY               - Device or resource busy
>
> I don't think that elaborate description of error values is needed, just "0
> on success and error code otherwise" would be sufficient.

/**
 * vm_insert_range - insert range of kernel pages into user vma
 * @vma: user vma to map to
 * @addr: target user address of this page
 * @pages: pointer to array of source kernel pages
 * @page_count: number of pages need to insert into user vma
 *
 * This allows drivers to insert range of kernel pages they've allocated
 * into a user vma. This is a generic function which drivers can use
 * rather than using their own way of mapping range of kernel pages into
 * user vma.
 *
 * Context: Process context. Called by mmap handlers.
 * Return: 0 on success and error code otherwise
 */
