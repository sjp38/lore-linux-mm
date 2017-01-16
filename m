Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 190A96B0038
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 14:41:03 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r126so29556327wmr.2
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 11:41:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f124si13527877wmd.64.2017.01.16.11.41.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Jan 2017 11:41:01 -0800 (PST)
Date: Mon, 16 Jan 2017 20:40:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/6] mm: introduce kv[mz]alloc helpers
Message-ID: <20170116194052.GA9382@dhcp22.suse.cz>
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-2-mhocko@kernel.org>
 <bf1815ec-766a-77f2-2823-c19abae5edb3@nvidia.com>
 <20170116084717.GA13641@dhcp22.suse.cz>
 <0ca8a212-c651-7915-af25-23925e1c1cc3@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0ca8a212-c651-7915-af25-23925e1c1cc3@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On Mon 16-01-17 11:09:37, John Hubbard wrote:
> 
> 
> On 01/16/2017 12:47 AM, Michal Hocko wrote:
> > On Sun 15-01-17 20:34:13, John Hubbard wrote:
[...]
> > > Is that "Reclaim modifiers" line still true, or is it a leftover from an
> > > earlier approach? I am having trouble reconciling it with rest of the
> > > patchset, because:
> > > 
> > > a) the flags argument below is effectively passed on to either kmalloc_node
> > > (possibly adding, but not removing flags), or to __vmalloc_node_flags.
> > 
> > The above only says thos are _unsupported_ - in other words the behavior
> > is not defined. Even if flags are passed down to kmalloc resp. vmalloc
> > it doesn't mean they are used that way.  Remember that vmalloc uses
> > some hardcoded GFP_KERNEL allocations.  So while I could be really
> > strict about this and mask away these flags I doubt this is worth the
> > additional code.
> 
> I do wonder about passing those flags through to kmalloc. Maybe it is worth
> stripping out __GFP_NORETRY and __GFP_NOFAIL, after all. It provides some
> insulation from any future changes to the implementation of kmalloc, and it
> also makes the documentation more believable.

I am not really convinced that we should take an extra steps for these
flags. There are no existing users for those flags and new users should
follow the documentation.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
