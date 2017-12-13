Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 060566B0260
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 08:05:01 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id a12so1072940pll.21
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 05:05:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r27si1246277pgn.85.2017.12.13.05.04.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Dec 2017 05:05:00 -0800 (PST)
Date: Wed, 13 Dec 2017 14:04:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mmap.2: MAP_FIXED updated documentation
Message-ID: <20171213130458.GI25185@dhcp22.suse.cz>
References: <20171213092550.2774-1-mhocko@kernel.org>
 <20171213093110.3550-1-mhocko@kernel.org>
 <20171213093110.3550-2-mhocko@kernel.org>
 <20171213125540.GA18897@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171213125540.GA18897@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Cyril Hrubis <chrubis@suse.cz>

On Wed 13-12-17 13:55:40, Pavel Machek wrote:
> On Wed 2017-12-13 10:31:10, Michal Hocko wrote:
> > From: John Hubbard <jhubbard@nvidia.com>
> > 
> >     -- Expand the documentation to discuss the hazards in
> >        enough detail to allow avoiding them.
> > 
> >     -- Mention the upcoming MAP_FIXED_SAFE flag.
> 
> Pretty map everyone agreed MAP_FIXED_SAFE was a bad
> name. MAP_FIXED_NOREPLACE (IIRC) was best replacement.

Please read http://lkml.kernel.org/r/20171213092550.2774-1-mhocko@kernel.org
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
