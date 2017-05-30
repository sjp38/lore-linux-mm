Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B77176B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 03:44:14 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g143so17931792wme.13
        for <linux-mm@kvack.org>; Tue, 30 May 2017 00:44:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k22si12202090edk.210.2017.05.30.00.44.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 May 2017 00:44:13 -0700 (PDT)
Date: Tue, 30 May 2017 09:44:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
Message-ID: <20170530074408.GA7969@dhcp22.suse.cz>
References: <20170522114243.2wrdbncilozygbpl@node.shutemov.name>
 <20170522133559.GE27382@rapoport-lnx>
 <20170522135548.GA8514@dhcp22.suse.cz>
 <20170522142927.GG27382@rapoport-lnx>
 <a9e74c22-1a07-f49a-42b5-497fee85e9c9@suse.cz>
 <20170524075043.GB3063@rapoport-lnx>
 <c59a0893-d370-130b-5c33-d567a4621903@suse.cz>
 <20170524103947.GC3063@rapoport-lnx>
 <20170524111800.GD14733@dhcp22.suse.cz>
 <20170524142735.GF3063@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170524142735.GF3063@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed 24-05-17 17:27:36, Mike Rapoport wrote:
> On Wed, May 24, 2017 at 01:18:00PM +0200, Michal Hocko wrote:
[...]
> > Why cannot khugepaged simply skip over all VMAs which have userfault
> > regions registered? This would sound like a less error prone approach to
> > me.
> 
> khugepaged does skip over VMAs which have userfault. We could register the
> regions with userfault before populating them to avoid collapses in the
> transition period.

Why cannot you register only post-copy regions and "manually" copy the
pre-copy parts?

> But then we'll have to populate these regions with
> UFFDIO_COPY which adds quite an overhead.

How big is the performance impact?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
