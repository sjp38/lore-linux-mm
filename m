Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id BF30F6B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 11:31:44 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id d24so3451236wmi.0
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 08:31:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j17si5469408wrc.475.2017.08.10.08.31.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Aug 2017 08:31:43 -0700 (PDT)
Date: Thu, 10 Aug 2017 17:31:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/2] mm,fork,security: introduce MADV_WIPEONFORK
Message-ID: <20170810153140.GB24628@dhcp22.suse.cz>
References: <20170806140425.20937-1-riel@redhat.com>
 <a0d79f77-f916-d3d6-1d61-a052581dbd4a@oracle.com>
 <bfdab709-e5b2-0d26-1c0f-31535eda1678@redhat.com>
 <1502198148.6577.18.camel@redhat.com>
 <0324df31-717d-32c1-95ef-351c5b23105f@oracle.com>
 <1502207168.6577.25.camel@redhat.com>
 <20170808165211.GE31390@bombadil.infradead.org>
 <1502217914.6577.32.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502217914.6577.32.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Florian Weimer <fweimer@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, colm@allcosts.net, akpm@linux-foundation.org, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com

On Tue 08-08-17 14:45:14, Rik van Riel wrote:
> On Tue, 2017-08-08 at 09:52 -0700, Matthew Wilcox wrote:
> > On Tue, Aug 08, 2017 at 11:46:08AM -0400, Rik van Riel wrote:
> > > On Tue, 2017-08-08 at 08:19 -0700, Mike Kravetz wrote:
> > > > If the use case is fairly specific, then perhaps it makes sense
> > > > to
> > > > make MADV_WIPEONFORK not applicable (EINVAL) for mappings where
> > > > the
> > > > result is 'questionable'.
> > > 
> > > That would be a question for Florian and Colm.
> > > 
> > > If they are OK with MADV_WIPEONFORK only working on
> > > anonymous VMAs (no file mapping), that certainly could
> > > be implemented.
> > > 
> > > On the other hand, I am not sure that introducing cases
> > > where MADV_WIPEONFORK does not implement wipe-on-fork
> > > semantics would reduce user confusion...
> > 
> > It'll simply do exactly what it does today, so it won't introduce any
> > new fallback code.
> 
> Sure, but actually implementing MADV_WIPEONFORK in a
> way that turns file mapped VMAs into zero page backed
> anonymous VMAs after fork takes no more code than
> implementing it in a way that refuses to work on VMAs
> that have a file backing.
> 
> There is no complexity argument for or against either
> approach.
> 
> The big question is, what is the best for users?
> 
> Should we return -EINVAL when MADV_WIPEONFORK is called
> on a VMA that has a file backing, and only succeed on
> anonymous VMAs?

I would rather be conservative and implement the bare minimum until
there is a reasonable usecase to demand the feature for shared mappings
as well.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
