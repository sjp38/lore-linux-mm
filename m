Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CDBE46B0005
	for <linux-mm@kvack.org>; Wed,  2 May 2018 20:52:29 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g1so14177915pfh.19
        for <linux-mm@kvack.org>; Wed, 02 May 2018 17:52:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p1-v6si7957797plb.204.2018.05.02.17.52.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 02 May 2018 17:52:28 -0700 (PDT)
Date: Wed, 2 May 2018 17:52:23 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 07/16] slub: Remove page->counters
Message-ID: <20180503005223.GB21199@bombadil.infradead.org>
References: <20180430202247.25220-1-willy@infradead.org>
 <20180430202247.25220-8-willy@infradead.org>
 <alpine.DEB.2.21.1805011148060.16325@nuc-kabylake>
 <20180502172639.GC2737@bombadil.infradead.org>
 <20180502221702.a2ezdae6akchroze@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180502221702.a2ezdae6akchroze@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Christopher Lameter <cl@linux.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Thu, May 03, 2018 at 01:17:02AM +0300, Kirill A. Shutemov wrote:
> On Wed, May 02, 2018 at 05:26:39PM +0000, Matthew Wilcox wrote:
> > Option 2:
> > +                       union {
> > +                               unsigned long counters;
> > +                               struct {
> > +                                       unsigned inuse:16;
> > +                                       unsigned objects:15;
> > +                                       unsigned frozen:1;
> > +                               };
> > +                       };
> > 
> > Pro: Expresses exactly what we do.
> > Con: Back to five levels of indentation in struct page
> 
> The indentation issue can be fixed (to some extend) by declaring the union
> outside struct page and just use it inside.
> 
> I don't advocate for the approach, just listing the option.

Actually, you can't have an anonymous tagged union without -fms-extensions
(which got zero comments when I proposed it to lkml) or -fplan9-extensions
(which would require gcc 4.6)
