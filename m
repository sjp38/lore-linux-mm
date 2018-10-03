Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A5B736B026F
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 12:22:40 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id ce7-v6so5794623plb.22
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 09:22:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 15-v6si1979954pfr.242.2018.10.03.09.22.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 09:22:39 -0700 (PDT)
Date: Wed, 3 Oct 2018 18:22:37 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/4] mm: introduce put_user_page(), placeholder version
Message-ID: <20181003162237.GH24030@quack2.suse.cz>
References: <20180928053949.5381-1-jhubbard@nvidia.com>
 <20180928053949.5381-4-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180928053949.5381-4-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

On Thu 27-09-18 22:39:48, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> Introduces put_user_page(), which simply calls put_page().
> This provides a way to update all get_user_pages*() callers,
> so that they call put_user_page(), instead of put_page().
> 
> Also adds release_user_pages(), a drop-in replacement for
> release_pages(). This is intended to be easily grep-able,
> for later performance improvements, since release_user_pages
> is not batched like release_pages() is, and is significantly
> slower.

A small nit but can we maybe call this put_user_pages() for symmetry with
put_user_page()? I don't really care too much but it would look natural to
me.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
