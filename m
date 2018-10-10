Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D64FA6B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 19:44:02 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id r81-v6so6270155pfk.11
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 16:44:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u22-v6si25383096pfn.111.2018.10.10.16.44.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 16:44:01 -0700 (PDT)
Date: Wed, 10 Oct 2018 16:43:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 2/3] mm: introduce put_user_page*(), placeholder
 versions
Message-Id: <20181010164359.292d938b51cbd57b38a1bd99@linux-foundation.org>
In-Reply-To: <62492f47-d51f-5c41-628c-ff17de21829e@nvidia.com>
References: <20181008211623.30796-1-jhubbard@nvidia.com>
	<20181008211623.30796-3-jhubbard@nvidia.com>
	<20181008171442.d3b3a1ea07d56c26d813a11e@linux-foundation.org>
	<20181009083025.GE11150@quack2.suse.cz>
	<20181009162012.c662ef0b041993557e150035@linux-foundation.org>
	<62492f47-d51f-5c41-628c-ff17de21829e@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>, john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Ralph Campbell <rcampbell@nvidia.com>

On Tue, 9 Oct 2018 17:32:16 -0700 John Hubbard <jhubbard@nvidia.com> wrote:

> > I'm not really understanding.  Patch 3/3 changes just one infiniband
> > driver to use put_user_page().  But the changelogs here imply (to me)
> > that every user of get_user_pages() needs to be converted to
> > s/put_page/put_user_page/.
> > 
> > Methinks a bit more explanation is needed in these changelogs?
> > 
> 
> OK, yes, it does sound like the explanation is falling short. I'll work on something 
> clearer. Did the proposed steps in the changelogs, such as:
>   
> [2] https://lkml.kernel.org/r/20180709080554.21931-1-jhubbard@nvidia.com
>     Proposed steps for fixing get_user_pages() + DMA problems.
> 
> help at all, or is it just too many references, and I should write the words
> directly in the changelog?
> 
> Anyway, patch 3/3 is a just a working example (which we do want to submit, though), and
> many more conversions will follow. But they don't have to be done all upfront--they
> can be done in follow up patchsets. 
> 
> The put_user_page*() routines are, at this point, not going to significantly change
> behavior. 
> 
> I'm working on an RFC that will show what the long-term fix to get_user_pages and
> put_user_pages will look like. But meanwhile it's good to get started on converting
> all of the call sites.

I see.  Yes, please do put all of it into the changelog[s].
