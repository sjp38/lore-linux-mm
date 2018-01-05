Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 726CC6B0536
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 14:44:16 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id w18so3107235wra.5
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 11:44:16 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k127si4167324wmd.3.2018.01.05.11.44.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Jan 2018 11:44:15 -0800 (PST)
Date: Fri, 5 Jan 2018 20:44:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm, numa: rework do_pages_move
Message-ID: <20180105194413.GU2801@dhcp22.suse.cz>
References: <20180103082555.14592-2-mhocko@kernel.org>
 <db9b9752-a106-a3af-12f5-9894adee7ba7@linux.vnet.ibm.com>
 <20180105091443.GJ2801@dhcp22.suse.cz>
 <ebef70ed-1eff-8406-f26b-3ed260c0db22@linux.vnet.ibm.com>
 <20180105093301.GK2801@dhcp22.suse.cz>
 <alpine.DEB.2.20.1801051113170.25466@nuc-kabylake>
 <20180105180905.GR2801@dhcp22.suse.cz>
 <alpine.DEB.2.20.1801051237300.26065@nuc-kabylake>
 <20180105184808.GS2801@dhcp22.suse.cz>
 <alpine.DEB.2.20.1801051326490.28069@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1801051326490.28069@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrea Reale <ar@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 05-01-18 13:27:48, Cristopher Lameter wrote:
> On Fri, 5 Jan 2018, Michal Hocko wrote:
> 
> > > Also why are you migrating the pages on pagelist if a
> > > add_page_for_migration() fails? One could simply update
> > > the status in user space and continue.
> >
> > I am open to further cleanups. Care to send a full patch with the
> > changelog? I would rather not fold more changes to the already tested
> > one.
> 
> While doing that I saw that one could pull the rwsem locking out of
> add_page_for_migration() as well in order to avoid taking it for each 4k
> page. Include that?

Yeah, why not if the end result turns out to be simpler and easier to
maintain. Please note that I was mostly after simplicity. There are
other things to sort out though. Please read the cover which contains
several API oddities which would be good to either sort out or at least
document them.

Please also note that I am too busy with the most "popular" bug these
days, unfortunately, so my review bandwidth will be very limited.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
