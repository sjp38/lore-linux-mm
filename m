Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id A23896B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 15:35:00 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so514833pac.0
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 12:35:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y5si14282240pas.206.2015.08.21.12.34.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Aug 2015 12:34:59 -0700 (PDT)
Date: Fri, 21 Aug 2015 12:34:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
Message-Id: <20150821123458.b3a6947135d5b506a34abc61@linux-foundation.org>
In-Reply-To: <20150821193109.GA14785@node.dhcp.inet.fi>
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1439976106-137226-5-git-send-email-kirill.shutemov@linux.intel.com>
	<20150820163643.dd87de0c1a73cb63866b2914@linux-foundation.org>
	<20150821121028.GB12016@node.dhcp.inet.fi>
	<alpine.DEB.2.11.1508211109460.27769@east.gentwo.org>
	<20150821193109.GA14785@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 21 Aug 2015 22:31:09 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Fri, Aug 21, 2015 at 11:11:27AM -0500, Christoph Lameter wrote:
> > On Fri, 21 Aug 2015, Kirill A. Shutemov wrote:
> > 
> > > > Is this really true?  For example if it's a slab page, will that page
> > > > ever be inspected by code which is looking for the PageTail bit?
> > >
> > > +Christoph.
> > >
> > > What we know for sure is that space is not used in tail pages, otherwise
> > > it would collide with current compound_dtor.
> > 
> > Sl*b allocators only do a virt_to_head_page on tail pages.
> 
> The question was whether it's safe to assume that the bit 0 is always zero
> in the word as this bit will encode PageTail().

That wasn't my question actually...

What I'm wondering is: if this page is being used for slab, will any
code path ever run PageTail() against it?  If not, we don't need to be
concerned about that bit.

And slab was just the example I chose.  The same question petains to
all other uses of that union.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
