Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E89E6B256F
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 09:30:27 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id v11so8636722ply.4
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 06:30:27 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 16si45832672pgh.58.2018.11.21.06.30.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 06:30:25 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH 1/9] mm: Introduce new vm_insert_range API
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20181121123513.GF3065@bombadil.infradead.org>
Date: Wed, 21 Nov 2018 07:29:37 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <D13F3DA0-1CD3-43AF-BAF6-5103FE7C4B5A@oracle.com>
References: <20181115154530.GA27872@jordon-HP-15-Notebook-PC>
 <20181116182836.GB17088@rapoport-lnx>
 <CAFqt6zYp0j999WXw9Jus0oZMjADQQkPfso8btv6du6L9CE3PXA@mail.gmail.com>
 <20181117143742.GB7861@bombadil.infradead.org>
 <CAFqt6zbOWX5LUTWwoGDJsGdf+pTR6N1yTPVxyr1W3-6Fte39ww@mail.gmail.com>
 <833B5050-DEF6-44A0-9832-276F86671212@oracle.com>
 <20181121123513.GF3065@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, rppt@linux.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, Rik van Riel <riel@surriel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com, Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, treding@nvidia.com, Kees Cook <keescook@chromium.org>, Marek Szyprowski <m.szyprowski@samsung.com>, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org, pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org, iommu@lists.linux-foundation.org, linux-media@vger.kernel.org



> On Nov 21, 2018, at 5:35 AM, Matthew Wilcox <willy@infradead.org> =
wrote:
>=20
> It's probably better to be more explicit and answer Randy's question:
>=20
> * If we fail to insert any page into the vma, the function will return
> * immediately leaving any previously-inserted pages present.  Callers
> * from the mmap handler may immediately return the error as their
> * caller will destroy the vma, removing any successfully-inserted =
pages.
> * Other callers should make their own arrangements for calling =
unmap_region().

That works for me as well.
