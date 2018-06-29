Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 452EB6B0005
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 01:58:00 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a12-v6so3933299pfn.12
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 22:58:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e82-v6si2491450pfh.64.2018.06.28.22.57.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Jun 2018 22:57:58 -0700 (PDT)
Date: Thu, 28 Jun 2018 22:57:54 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH -mm -v4 00/21] mm, THP, swap: Swapout/swapin THP in one
 piece
Message-ID: <20180629055754.GH7646@bombadil.infradead.org>
References: <20180622035151.6676-1-ying.huang@intel.com>
 <20180627215144.73e98b01099191da59bff28c@linux-foundation.org>
 <87r2krfpi2.fsf@yhuang-dev.intel.com>
 <20180627223118.dd2f52d87f53e7e002ed0153@linux-foundation.org>
 <87muvffp7w.fsf@yhuang-dev.intel.com>
 <20180627231839.e5ac2f38e0397979d3db7765@linux-foundation.org>
 <20180628090301.GC7646@bombadil.infradead.org>
 <87woui9ysj.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87woui9ysj.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>

On Fri, Jun 29, 2018 at 09:17:16AM +0800, Huang, Ying wrote:
> Matthew Wilcox <willy@infradead.org> writes:
> > I'll take a look.  Honestly, my biggest problem with this patch set is
> > overuse of tagging:
> >
> > 59832     Jun 22 Huang, Ying     ( 131) [PATCH -mm -v4 00/21] mm, THP, swap: Swa
> > There's literally zero useful information displayed in the patch subjects.
> 
> Thanks!  What's your suggestion on tagging?  Only keep "mm" or "swap"?

Subject: [PATCH v14 10/74] xarray: Add XArray tags

I'm not sure where the extra '-' in front of '-v4' comes from.  I also
wouldn't put the '-mm' in front of it -- that information can live in
the cover letter's body rather than any patch's subject.

I think 'swap:' implies "mm:", so yeah I'd just go with that.

Subject: [PATCH v4 00/21] swap: Useful information here

I'd see that as:

59832     Jun 22 Huang, Ying     ( 131) [PATCH v4 00/21] swap: Useful informatio

I had a quick look at your patches.  I think only two are affected by
the XArray, and I'll make some general comments about them soon.
