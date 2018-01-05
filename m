Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1488028027A
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 13:09:09 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id f132so790711wmf.6
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 10:09:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p14si4659193wrd.48.2018.01.05.10.09.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Jan 2018 10:09:07 -0800 (PST)
Date: Fri, 5 Jan 2018 19:09:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm, numa: rework do_pages_move
Message-ID: <20180105180905.GR2801@dhcp22.suse.cz>
References: <20180103082555.14592-1-mhocko@kernel.org>
 <20180103082555.14592-2-mhocko@kernel.org>
 <db9b9752-a106-a3af-12f5-9894adee7ba7@linux.vnet.ibm.com>
 <20180105091443.GJ2801@dhcp22.suse.cz>
 <ebef70ed-1eff-8406-f26b-3ed260c0db22@linux.vnet.ibm.com>
 <20180105093301.GK2801@dhcp22.suse.cz>
 <alpine.DEB.2.20.1801051113170.25466@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1801051113170.25466@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrea Reale <ar@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 05-01-18 11:15:18, Cristopher Lameter wrote:
> On Fri, 5 Jan 2018, Michal Hocko wrote:
> 
> > Yes. I am really wondering because there souldn't anything specific to
> > improve the situation with patch 2 and 3. Likewise the only overhead
> > from the patch 1 I can see is the reduced batching of the mmap_sem. But
> > then I am wondering what would compensate that later...
> 
> Could you reduce the frequency of taking mmap_sem? Maybe take it when
> picking a new node and drop it when done with that node before migrating
> the list of pages?

I believe there should be some cap on the number of pages. We shouldn't
keep it held for million of pages if all of them are moved to the same
node. I would really like to postpone that to later unless it causes
some noticeable regressions because this would complicate the code
further and I am not sure this is all worth it.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
