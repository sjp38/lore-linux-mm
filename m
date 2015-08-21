Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id E19226B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 12:11:30 -0400 (EDT)
Received: by iodb91 with SMTP id b91so86497180iod.1
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 09:11:30 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id e31si1701211iod.168.2015.08.21.09.11.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 21 Aug 2015 09:11:29 -0700 (PDT)
Date: Fri, 21 Aug 2015 11:11:27 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
In-Reply-To: <20150821121028.GB12016@node.dhcp.inet.fi>
Message-ID: <alpine.DEB.2.11.1508211109460.27769@east.gentwo.org>
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com> <1439976106-137226-5-git-send-email-kirill.shutemov@linux.intel.com> <20150820163643.dd87de0c1a73cb63866b2914@linux-foundation.org> <20150821121028.GB12016@node.dhcp.inet.fi>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 21 Aug 2015, Kirill A. Shutemov wrote:

> > Is this really true?  For example if it's a slab page, will that page
> > ever be inspected by code which is looking for the PageTail bit?
>
> +Christoph.
>
> What we know for sure is that space is not used in tail pages, otherwise
> it would collide with current compound_dtor.

Sl*b allocators only do a virt_to_head_page on tail pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
