Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 12F546B006E
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 14:30:50 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so1311426pdb.3
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 11:30:49 -0700 (PDT)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id ib4si50132pbb.168.2015.03.24.11.30.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 11:30:49 -0700 (PDT)
Message-ID: <1427221835.2515.52.camel@j-VirtualBox>
Subject: Re: [PATCH] mm: Remove usages of ACCESS_ONCE
From: Jason Low <jason.low2@hp.com>
Date: Tue, 24 Mar 2015 11:30:35 -0700
In-Reply-To: <20150324103003.GC14241@dhcp22.suse.cz>
References: <1427150680.2515.36.camel@j-VirtualBox>
	 <20150324103003.GC14241@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Aswin Chandramouleeswaran <aswin@hp.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Davidlohr Bueso <dave@stgolabs.net>, Rik van Riel <riel@redhat.com>, jason.low2@hp.com

On Tue, 2015-03-24 at 11:30 +0100, Michal Hocko wrote:
> On Mon 23-03-15 15:44:40, Jason Low wrote:
> > Commit 38c5ce936a08 converted ACCESS_ONCE usage in gup_pmd_range() to
> > READ_ONCE, since ACCESS_ONCE doesn't work reliably on non-scalar types.
> > 
> > This patch removes the rest of the usages of ACCESS_ONCE, and use
> > READ_ONCE for the read accesses. This also makes things cleaner,
> > instead of using separate/multiple sets of APIs.
> > 
> > Signed-off-by: Jason Low <jason.low2@hp.com>
> 
> Makes sense to me. I would prefer a patch split into two parts. One which
> changes potentially dangerous usage of ACCESS_ONCE and the cleanup. This
> will make the life of those who backport patches into older kernels
> easier a bit.

Okay, so have a patch 1 which fixes the following:

    pte_t pte = ACCESS_ONCE(*ptep);
    pgd_t pgd = ACCESS_ONCE(*pgdp);

and the rest of the changes in the cleanup patch 2?

> I won't insist though.
> 
> Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks,
Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
