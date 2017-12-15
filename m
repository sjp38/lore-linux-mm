Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B27086B0038
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 04:57:54 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id o16so3854896wmf.4
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 01:57:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j10si4807711wrc.446.2017.12.15.01.57.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Dec 2017 01:57:53 -0800 (PST)
Date: Fri, 15 Dec 2017 10:57:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/3] mm, numa: rework do_pages_move
Message-ID: <20171215095751.GW16951@dhcp22.suse.cz>
References: <20171207143401.GK20234@dhcp22.suse.cz>
 <20171208161559.27313-1-mhocko@kernel.org>
 <20171208161559.27313-2-mhocko@kernel.org>
 <20171213143948.GM25185@dhcp22.suse.cz>
 <20171214153558.trgov6dbclav6ui7@node.shutemov.name>
 <20171215092859.GT16951@dhcp22.suse.cz>
 <20171215095125.s6zl7qoaabhpzugz@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171215095125.s6zl7qoaabhpzugz@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Fri 15-12-17 12:51:25, Kirill A. Shutemov wrote:
> On Fri, Dec 15, 2017 at 10:28:59AM +0100, Michal Hocko wrote:
> > On Thu 14-12-17 18:35:58, Kirill A. Shutemov wrote:
> > > On Wed, Dec 13, 2017 at 03:39:48PM +0100, Michal Hocko wrote:
> > [...]
> > > > +	err = 0;
> > > > +	if (page_to_nid(page) == node)
> > > > +		goto out_putpage;
> > > > +
> > > > +	err = -EACCES;
> > > > +	if (page_mapcount(page) > 1 &&
> > > > +			!migrate_all)
> > > 
> > > Non-sensible line break.
> > 
> > fixed
> > 
> > > > +		goto out_putpage;
> > > > +
> > > > +	if (PageHuge(page)) {
> > > > +		if (PageHead(page)) {
> > > > +			isolate_huge_page(page, pagelist);
> > > > +			err = 0;
> > > > +		}
> > > > +	} else {
> > > 
> > > Hm. I think if the page is PageTail() we have to split the huge page.
> > > If an user asks to migrate part of THP, we shouldn't migrate the whole page,
> > > otherwise it's not transparent anymore.
> > 
> > Well, as I've said in the cover letter. There are more things which are
> > worth considering but I've tried to keep the original semantic so
> > further changes should be done in separete patches. I will work on those
> > but I would prefer this to stay smaller if you do not mind.
> 
> Sure.
> 
> Fill free to use my ack.

Thanks a lot Kirill! I will wait for some more feedback and then
resubmit later next week.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
