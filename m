Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BBACE8E0004
	for <linux-mm@kvack.org>; Sat,  8 Dec 2018 13:13:04 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id u20so6264396pfa.1
        for <linux-mm@kvack.org>; Sat, 08 Dec 2018 10:13:04 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w11si6317720pfk.210.2018.12.08.10.13.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 08 Dec 2018 10:13:03 -0800 (PST)
Date: Sat, 8 Dec 2018 10:12:58 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181208181258.GA13075@infradead.org>
References: <20181205011519.GV10377@bombadil.infradead.org>
 <20181205014441.GA3045@redhat.com>
 <59ca5c4b-fd5b-1fc6-f891-c7986d91908e@nvidia.com>
 <7b4733be-13d3-c790-ff1b-ac51b505e9a6@nvidia.com>
 <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <CAPcyv4hwtMA+4qc6500ucn5vf6fRrNdfyMHru_Jhzx86=1Wwww@mail.gmail.com>
 <20181208163353.GA2952@redhat.com>
 <20181208164825.GA26154@infradead.org>
 <CAPcyv4hP1XrheKTrapANmrg10xz6dpG7cj=qEG8La9L34bCKDQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hP1XrheKTrapANmrg10xz6dpG7cj=qEG8La9L34bCKDQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Sat, Dec 08, 2018 at 10:09:26AM -0800, Dan Williams wrote:
> Another fix that may put pressure 'struct page' is resolving the
> untenable situation of dax being incompatible with reflink, i.e.
> reflink currently requires page-cache pages. Dave has talked about
> silently establishing page-cache entries when a dax-page is cow'd for
> reflink, but I wonder if we could go the other way and introduce the
> mechanism of a page belonging to multiple mappings simultaneously and
> managed by the filesystem.

FYI, I had a a prototype for DAX + reflink that didn't require
the page cache, although it badly reimplemented parts of it.  But
that was a long time ago, before we started requiring struct page
for the DAX memory.
