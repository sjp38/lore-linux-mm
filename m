Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2A92D6B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 10:56:37 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 10so20025211wml.4
        for <linux-mm@kvack.org>; Tue, 30 May 2017 07:56:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c14si14565027edf.153.2017.05.30.07.56.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 May 2017 07:56:35 -0700 (PDT)
Date: Tue, 30 May 2017 16:56:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
Message-ID: <20170530145632.GL7969@dhcp22.suse.cz>
References: <20170524075043.GB3063@rapoport-lnx>
 <c59a0893-d370-130b-5c33-d567a4621903@suse.cz>
 <20170524103947.GC3063@rapoport-lnx>
 <20170524111800.GD14733@dhcp22.suse.cz>
 <20170524142735.GF3063@rapoport-lnx>
 <20170530074408.GA7969@dhcp22.suse.cz>
 <20170530101921.GA25738@rapoport-lnx>
 <20170530103930.GB7969@dhcp22.suse.cz>
 <20170530140456.GA8412@redhat.com>
 <20170530143941.GK7969@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170530143941.GK7969@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Tue 30-05-17 16:39:41, Michal Hocko wrote:
> On Tue 30-05-17 16:04:56, Andrea Arcangeli wrote:
[...]
> > About the proposed madvise, it just clear bits, but it doesn't change
> > at all how those bits are computed in THP code. So I don't see it as
> > convoluted.
> 
> But we already have MADV_HUGEPAGE, MADV_NOHUGEPAGE and prctl to
> enable/disable thp. Doesn't that sound little bit too much for a single
> feature to you?

And also I would argue that the prctl should be usable for this specific
usecase. The man page says
"
Setting this flag provides a method for disabling transparent huge pages
for jobs where the code cannot be modified
"

and that fits into the described case AFAIU. The thing that the current
implementation doesn't work is a mere detail. I would even argue that
it is non-intuitive if not buggy right away. Whoever calls this prctl
later in the process life time will simply not stop THP from creating.

So again, why cannot we fix that? There was some handwaving about
potential overhead but has anybody actually measured that?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
