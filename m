Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F406428025D
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 13:48:12 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id h18so3201139pfi.2
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 10:48:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c67si4413475pfl.262.2018.01.05.10.48.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Jan 2018 10:48:11 -0800 (PST)
Date: Fri, 5 Jan 2018 19:48:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm, numa: rework do_pages_move
Message-ID: <20180105184808.GS2801@dhcp22.suse.cz>
References: <20180103082555.14592-1-mhocko@kernel.org>
 <20180103082555.14592-2-mhocko@kernel.org>
 <db9b9752-a106-a3af-12f5-9894adee7ba7@linux.vnet.ibm.com>
 <20180105091443.GJ2801@dhcp22.suse.cz>
 <ebef70ed-1eff-8406-f26b-3ed260c0db22@linux.vnet.ibm.com>
 <20180105093301.GK2801@dhcp22.suse.cz>
 <alpine.DEB.2.20.1801051113170.25466@nuc-kabylake>
 <20180105180905.GR2801@dhcp22.suse.cz>
 <alpine.DEB.2.20.1801051237300.26065@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1801051237300.26065@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrea Reale <ar@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 05-01-18 12:41:22, Cristopher Lameter wrote:
> On Fri, 5 Jan 2018, Michal Hocko wrote:
> 
> > I believe there should be some cap on the number of pages. We shouldn't
> > keep it held for million of pages if all of them are moved to the same
> > node. I would really like to postpone that to later unless it causes
> > some noticeable regressions because this would complicate the code
> > further and I am not sure this is all worth it.
> 
> Attached a patch to make the code more readable.
> 
> Also why are you migrating the pages on pagelist if a
> add_page_for_migration() fails? One could simply update
> the status in user space and continue.

I am open to further cleanups. Care to send a full patch with the
changelog? I would rather not fold more changes to the already tested
one.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
