Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E5B26B0007
	for <linux-mm@kvack.org>; Thu,  3 May 2018 11:03:12 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id d5-v6so13057914qtg.17
        for <linux-mm@kvack.org>; Thu, 03 May 2018 08:03:12 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id t43-v6si2058948qte.388.2018.05.03.08.03.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 08:03:11 -0700 (PDT)
Date: Thu, 3 May 2018 10:03:10 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v4 07/16] slub: Remove page->counters
In-Reply-To: <20180503005223.GB21199@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.21.1805031001510.6701@nuc-kabylake>
References: <20180430202247.25220-1-willy@infradead.org> <20180430202247.25220-8-willy@infradead.org> <alpine.DEB.2.21.1805011148060.16325@nuc-kabylake> <20180502172639.GC2737@bombadil.infradead.org> <20180502221702.a2ezdae6akchroze@black.fi.intel.com>
 <20180503005223.GB21199@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>

On Wed, 2 May 2018, Matthew Wilcox wrote:

> > > Option 2:
> > > +                       union {
> > > +                               unsigned long counters;
> > > +                               struct {
> > > +                                       unsigned inuse:16;
> > > +                                       unsigned objects:15;
> > > +                                       unsigned frozen:1;
> > > +                               };
> > > +                       };
> > >
> > > Pro: Expresses exactly what we do.
> > > Con: Back to five levels of indentation in struct page

I like that better. Improves readability of the code using struct page. I
think that is more important than the actual definition of struct page.

Given the overloaded overload situation this will require some deep
throught for newbies anyways. ;-)
