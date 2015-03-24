Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4CBE26B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 12:58:39 -0400 (EDT)
Received: by oifl3 with SMTP id l3so143136042oif.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 09:58:39 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id s14si2717411oeo.22.2015.03.24.09.58.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 09:58:38 -0700 (PDT)
Message-ID: <1427216312.2515.46.camel@j-VirtualBox>
Subject: Re: [PATCH] mm: Remove usages of ACCESS_ONCE
From: Jason Low <jason.low2@hp.com>
Date: Tue, 24 Mar 2015 09:58:32 -0700
In-Reply-To: <551177F0.3070006@de.ibm.com>
References: <1427150680.2515.36.camel@j-VirtualBox>
	 <551177F0.3070006@de.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Aswin Chandramouleeswaran <aswin@hp.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Davidlohr Bueso <dave@stgolabs.net>, Rik van Riel <riel@redhat.com>, jason.low2@hp.com

On Tue, 2015-03-24 at 15:42 +0100, Christian Borntraeger wrote:
> Am 23.03.2015 um 23:44 schrieb Jason Low:
> > Commit 38c5ce936a08 converted ACCESS_ONCE usage in gup_pmd_range() to
> > READ_ONCE, since ACCESS_ONCE doesn't work reliably on non-scalar types.
> > 
> > This patch removes the rest of the usages of ACCESS_ONCE, and use
> > READ_ONCE for the read accesses. This also makes things cleaner,
> > instead of using separate/multiple sets of APIs.
> > 
> > Signed-off-by: Jason Low <jason.low2@hp.com>
> 
> Reviewed-by: Christian Borntraeger <borntraeger@de.ibm.com>

Thanks.

> one remark or question:
> 
> > -	anon_mapping = (unsigned long) ACCESS_ONCE(page->mapping);
> > +	anon_mapping = (unsigned long)READ_ONCE(page->mapping);
> 
> Were the white space changes intentional? IIRC checkpatch does prefer
> it your way and you have changed several places - so I assume yes.

Yeah, those changes were intentional.

I thought that this was more of the standard style to do casting, so I
made those changes as well.

> Either way, its probably fine to change that along.

Okay, I'll assume that this is fine for now unless something thinks this
shouldn't be part of the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
