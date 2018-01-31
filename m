Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8CADF6B0007
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 08:26:01 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id f3so2267875wmc.8
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 05:26:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 19si11277918wmv.97.2018.01.31.05.25.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Jan 2018 05:25:59 -0800 (PST)
Date: Wed, 31 Jan 2018 14:25:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm/swap.c: make functions and their kernel-doc agree
Message-ID: <20180131132558.GU21609@dhcp22.suse.cz>
References: <3b42ee3e-04a9-a6ca-6be4-f00752a114fe@infradead.org>
 <20180130123400.GD26445@dhcp22.suse.cz>
 <20180131075848.GB28275@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180131075848.GB28275@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>

On Tue 30-01-18 23:58:48, Matthew Wilcox wrote:
> On Tue, Jan 30, 2018 at 01:34:00PM +0100, Michal Hocko wrote:
> > On Mon 29-01-18 16:43:55, Randy Dunlap wrote:
> > > - for function pagevec_lookup_entries(), change the function parameter
> > >   name from nr_pages to nr_entries since that is more descriptive of
> > >   what the parameter actually is and then it matches the kernel-doc
> > >   comments also
> > 
> > I know what is nr_pages because I do expect pages to be returned. What
> > are entries? Can it be something different from pages?
> 
> entries are any page cache entries -- pages or exceptional entries.

Fair point.

> calling this parameter nr_pages tricks you into thinking that you'll
> only get pages back.

Well, the data structure we are using is a pagevec and that operates on
top of struct pages. It is true that this is quite confusing especially
for those who are not familiar with exceptional entries. Hopefully the
associated documentation helps.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
