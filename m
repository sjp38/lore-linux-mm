Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B5E6E6B0008
	for <linux-mm@kvack.org>; Tue, 29 May 2018 04:21:33 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b25-v6so8710060pfn.10
        for <linux-mm@kvack.org>; Tue, 29 May 2018 01:21:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g63-v6si25302833pgc.40.2018.05.29.01.21.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 May 2018 01:21:32 -0700 (PDT)
Date: Tue, 29 May 2018 10:21:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] doc: document scope NOFS, NOIO APIs
Message-ID: <20180529082130.GO27180@dhcp22.suse.cz>
References: <20180424183536.GF30619@thunk.org>
 <20180524114341.1101-1-mhocko@kernel.org>
 <20180524221715.GY10363@dastard>
 <20180525081624.GH11881@dhcp22.suse.cz>
 <20180527124721.GA4522@rapoport-lnx>
 <20180528092138.GI1517@dhcp22.suse.cz>
 <d2f6c4c1-856a-d233-8610-67a868b856f9@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d2f6c4c1-856a-d233-8610-67a868b856f9@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Jonathan Corbet <corbet@lwn.net>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, "Darrick J. Wong" <darrick.wong@oracle.com>, David Sterba <dsterba@suse.cz>

On Mon 28-05-18 09:10:43, Randy Dunlap wrote:
> On 05/28/2018 02:21 AM, Michal Hocko wrote:
[...]
> > +reclaim context or when a transaction context nesting would be possible
> > +via reclaim. The corresponding restore function when the critical
> 
> "The corresponding restore ... ends."  << That is not a complete sentence.
> It's missing something.

Dave has pointed that out.
"The restore function should be called when the critical section ends."

> > +section ends. All that ideally along with an explanation what is
> > +the reclaim context for easier maintenance.
> > +
> > +Please note that the proper pairing of save/restore function allows
> > +nesting so it is safe to call ``memalloc_noio_save`` respectively
> > +``memalloc_noio_restore`` from an existing NOIO or NOFS scope.
> 
> Please note that the proper pairing of save/restore functions allows
> nesting so it is safe to call ``memalloc_noio_save`` or
> ``memalloc_noio_restore`` respectively from an existing NOIO or NOFS scope.

Fixed. Thanks
-- 
Michal Hocko
SUSE Labs
