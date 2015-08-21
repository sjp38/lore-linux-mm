Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 58EE36B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 15:31:18 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so23617701wid.0
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 12:31:17 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id un9si16685383wjc.60.2015.08.21.12.31.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Aug 2015 12:31:16 -0700 (PDT)
Received: by widdq5 with SMTP id dq5so150183wid.1
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 12:31:16 -0700 (PDT)
Date: Fri, 21 Aug 2015 22:31:09 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
Message-ID: <20150821193109.GA14785@node.dhcp.inet.fi>
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439976106-137226-5-git-send-email-kirill.shutemov@linux.intel.com>
 <20150820163643.dd87de0c1a73cb63866b2914@linux-foundation.org>
 <20150821121028.GB12016@node.dhcp.inet.fi>
 <alpine.DEB.2.11.1508211109460.27769@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1508211109460.27769@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Aug 21, 2015 at 11:11:27AM -0500, Christoph Lameter wrote:
> On Fri, 21 Aug 2015, Kirill A. Shutemov wrote:
> 
> > > Is this really true?  For example if it's a slab page, will that page
> > > ever be inspected by code which is looking for the PageTail bit?
> >
> > +Christoph.
> >
> > What we know for sure is that space is not used in tail pages, otherwise
> > it would collide with current compound_dtor.
> 
> Sl*b allocators only do a virt_to_head_page on tail pages.

The question was whether it's safe to assume that the bit 0 is always zero
in the word as this bit will encode PageTail().

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
