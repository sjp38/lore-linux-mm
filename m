Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6D7746B028D
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:46:49 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id r20so11069974wrg.23
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 04:46:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j6si2076411wrd.210.2017.12.19.04.46.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 04:46:48 -0800 (PST)
Date: Tue, 19 Dec 2017 13:46:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/2] mm: introduce MAP_FIXED_SAFE
Message-ID: <20171219124646.GR2787@dhcp22.suse.cz>
References: <20171213092550.2774-1-mhocko@kernel.org>
 <20171213163210.6a16ccf8753b74a6982ef5b6@linux-foundation.org>
 <CAFLM3-oANXKEU=tuurSJx9rdzfWGfym-0FUEWnfBq8mOaVMzOA@mail.gmail.com>
 <20171214131526.GM16951@dhcp22.suse.cz>
 <20171214145443.GA2202@brick>
 <0ca2620ce7534c5491e69416621ac41b@AcuMS.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0ca2620ce7534c5491e69416621ac41b@AcuMS.aculab.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@ACULAB.COM>
Cc: 'Edward Napierala' <trasz@freebsd.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Kees Cook <keescook@chromium.org>, "jasone@google.com" <jasone@google.com>, "davidtgoldblatt@gmail.com" <davidtgoldblatt@gmail.com>

On Tue 19-12-17 12:40:16, David Laight wrote:
> From: Edward Napierala
> > Sent: 14 December 2017 14:55
> >
> > On 1214T1415, Michal Hocko wrote:
> > > On Thu 14-12-17 12:44:17, Edward Napierala wrote:
> > > > Regarding the name - how about adopting MAP_EXCL?  It was introduced in
> > > > FreeBSD,
> > > > and seems to do exactly this; quoting mmap(2):
> > > >
> > > > MAP_FIXED    Do not permit the system to select a different address
> > > >                         than the one specified.  If the specified address
> > > >                         cannot be used, mmap() will fail.  If MAP_FIXED is
> > > >                         specified, addr must be a multiple of the page size.
> > > >                         If MAP_EXCL is not specified, a successful MAP_FIXED
> > > >                         request replaces any previous mappings for the
> > > >                         process' pages in the range from addr to addr + len.
> > > >                         In contrast, if MAP_EXCL is specified, the request
> > > >                         will fail if a mapping already exists within the
> > > >                         range.
> > >
> > > I am not familiar with the FreeBSD implementation but from the above it
> > > looks like MAP_EXCL is a MAP_FIXED mofifier which is not how we are
> > > going to implement it in linux due to reasons mentioned in this cover
> > > letter. Using the same name would be more confusing than helpful I am
> > > afraid.
> > 
> > Sorry, missed that.  Indeed, reusing a name with a different semantics
> > would be a bad idea.
> 
> I don't remember any discussion about using MAP_FIXED | MAP_EXCL ?
> 
> Why not match the prior art??

See the cover letter which explains why an extension is not backward
compatible.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
