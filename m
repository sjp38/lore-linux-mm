Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 091196B1911
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 07:29:34 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id d23so18552696plj.22
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 04:29:33 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p14si14495615pfi.12.2018.11.19.04.29.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Nov 2018 04:29:32 -0800 (PST)
Date: Mon, 19 Nov 2018 04:29:29 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [Xen-devel] [PATCH 5/9] drm/xen/xen_drm_front_gem.c: Convert to
 use vm_insert_range
Message-ID: <20181119122929.GA394@bombadil.infradead.org>
References: <20181115154912.GA27969@jordon-HP-15-Notebook-PC>
 <ed294bea-bf07-6a4d-51ec-9e7082703b61@gmail.com>
 <CAFqt6zZ_FnWg2K3Lh=-1KFOk1XteHnroua6QzJrKo+khZTgieg@mail.gmail.com>
 <c76fc2fa-d08b-7db3-5693-d9c303cd7126@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c76fc2fa-d08b-7db3-5693-d9c303cd7126@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleksandr Andrushchenko <andr2000@gmail.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, oleksandr_andrushchenko@epam.com, airlied@linux.ie, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, xen-devel@lists.xen.org

On Mon, Nov 19, 2018 at 01:02:46PM +0200, Oleksandr Andrushchenko wrote:
> On 11/19/18 12:42 PM, Souptick Joarder wrote:
> > On Mon, Nov 19, 2018 at 3:22 PM Oleksandr Andrushchenko
> > <andr2000@gmail.com> wrote:
> > > > -     unsigned long addr = vma->vm_start;
> > > > -     int i;
> > > > +     int err;
> > > I would love to keep ret, not err
> > Sure, will add it in v2.
> > But I think, err is more appropriate here.
> 
> I used "ret" throughout the driver, so this is just to remain consistent:
> 
> grep -rnw err drivers/gpu/drm/xen/ | wc -l
> 0
> grep -rnw ret drivers/gpu/drm/xen/ | wc -l
> 204

It's your driver, so that's fine.  The reason we chose 'err' over 'ret'
is that there's a history of errno vs VM_FAULT_xxx code confusion in
this area.  Naming a variable 'err' makes it clear this is an errno and
not a vm_fault_t.

> > > With the above fixed,
> > > 
> > > Reviewed-by: Oleksandr Andrushchenko <oleksandr_andrushchenko@epam.com>

Thanks.
