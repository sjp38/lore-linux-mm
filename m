Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 483236B02F3
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 12:52:16 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j83so37565557pfe.10
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 09:52:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id r5si1249107pli.111.2017.08.08.09.52.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 09:52:15 -0700 (PDT)
Date: Tue, 8 Aug 2017 09:52:11 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 0/2] mm,fork,security: introduce MADV_WIPEONFORK
Message-ID: <20170808165211.GE31390@bombadil.infradead.org>
References: <20170806140425.20937-1-riel@redhat.com>
 <a0d79f77-f916-d3d6-1d61-a052581dbd4a@oracle.com>
 <bfdab709-e5b2-0d26-1c0f-31535eda1678@redhat.com>
 <1502198148.6577.18.camel@redhat.com>
 <0324df31-717d-32c1-95ef-351c5b23105f@oracle.com>
 <1502207168.6577.25.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502207168.6577.25.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Florian Weimer <fweimer@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, colm@allcosts.net, akpm@linux-foundation.org, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com

On Tue, Aug 08, 2017 at 11:46:08AM -0400, Rik van Riel wrote:
> On Tue, 2017-08-08 at 08:19 -0700, Mike Kravetz wrote:
> > If the use case is fairly specific, then perhaps it makes sense to
> > make MADV_WIPEONFORK not applicable (EINVAL) for mappings where the
> > result is 'questionable'.
> 
> That would be a question for Florian and Colm.
> 
> If they are OK with MADV_WIPEONFORK only working on
> anonymous VMAs (no file mapping), that certainly could
> be implemented.
> 
> On the other hand, I am not sure that introducing cases
> where MADV_WIPEONFORK does not implement wipe-on-fork
> semantics would reduce user confusion...

It'll simply do exactly what it does today, so it won't introduce any
new fallback code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
