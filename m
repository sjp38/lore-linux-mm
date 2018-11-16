Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id EDE6A6B0872
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 03:16:04 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id 6-v6so9677563ljv.21
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 00:16:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p10-v6sor16979977ljh.6.2018.11.16.00.16.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Nov 2018 00:16:03 -0800 (PST)
MIME-Version: 1.0
References: <20181115154530.GA27872@jordon-HP-15-Notebook-PC>
 <9655a12e-bd3d-aca2-6155-38924028eb5d@infradead.org> <CAFqt6zbLjtDab3Bz67trbnQRQdutvgA=YvAFhoW4bxsg657mGQ@mail.gmail.com>
 <20181116064049.GA5320@bombadil.infradead.org>
In-Reply-To: <20181116064049.GA5320@bombadil.infradead.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Fri, 16 Nov 2018 13:45:48 +0530
Message-ID: <CAFqt6zbL1tu4VWtZ5Wz-BgbOS+M2GJziMj958_h_ri4Th3n9bQ@mail.gmail.com>
Subject: Re: [PATCH 1/9] mm: Introduce new vm_insert_range API
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, Rik van Riel <riel@surriel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com, Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, treding@nvidia.com, Kees Cook <keescook@chromium.org>, Marek Szyprowski <m.szyprowski@samsung.com>, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org, pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org, iommu@lists.linux-foundation.org, linux-media@vger.kernel.org

On Fri, Nov 16, 2018 at 12:11 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Fri, Nov 16, 2018 at 11:00:30AM +0530, Souptick Joarder wrote:
> > On Thu, Nov 15, 2018 at 11:44 PM Randy Dunlap <rdunlap@infradead.org> wrote:
> > > On 11/15/18 7:45 AM, Souptick Joarder wrote:
> > > What is the opposite of vm_insert_range() or even of vm_insert_page()?
> > > or is there no need for that?
> >
> > There is no opposite function of vm_insert_range() / vm_insert_page().
> > My understanding is, in case of any error, mmap handlers will return the
> > err to user process and user space will decide the next action. So next
> > time when mmap handler is getting invoked it will map from the beginning.
> > Correct me if I am wrong.
>
> The opposite function, I suppose, is unmap_region().
>
> > > s/no./number/
> >
> > I didn't get it ??
>
> This is a 'sed' expression.  's' is the 'substitute' command; the /
> is a separator, 'no.' is what you wrote, and 'number' is what Randy
> is recommending instead.

Ok. Will change it in v2.
>
> > > > +     for (i = 0; i < page_count; i++) {
> > > > +             ret = vm_insert_page(vma, uaddr, pages[i]);
> > > > +             if (ret < 0)
> > > > +                     return ret;
> > >
> > > For a non-trivial value of page_count:
> > > Is it a problem if vm_insert_page() succeeds for several pages
> > > and then fails?
> >
> > No, it will be considered as total failure and mmap handler will return
> > the err to user space.
>
> I think what Randy means is "What happens to the inserted pages?" and
> the answer is that mmap_region() jumps to the 'unmap_and_free_vma'
> label, which is an accurate name.

Sorry for incorrect understanding of the question.
