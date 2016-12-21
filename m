Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 79D5C6B038B
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 03:45:11 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id hb5so58177883wjc.2
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 00:45:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 187si22905760wmx.141.2016.12.21.00.45.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Dec 2016 00:45:10 -0800 (PST)
Date: Wed, 21 Dec 2016 09:45:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm: introduce kv[mz]alloc helpers
Message-ID: <20161221084505.GA31118@dhcp22.suse.cz>
References: <20161208103300.23217-1-mhocko@kernel.org>
 <20161213101451.GB10492@dhcp22.suse.cz>
 <1481666853.29291.33.camel@perches.com>
 <20161214085916.GB25573@dhcp22.suse.cz>
 <20161220135016.GH3769@dhcp22.suse.cz>
 <1482255502.1984.21.camel@perches.com>
 <20161220141341.de8b22fd66ea9bc6c4fcf962@linux-foundation.org>
 <20161221065922.GB16502@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161221065922.GB16502@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joe Perches <joe@perches.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, LKML <linux-kernel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>, kvm@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org, Dave Chinner <david@fromorbit.com>, Al Viro <viro@zeniv.linux.org.uk>, Mikulas Patocka <mpatocka@redhat.com>

It seems that this email didn't get delivered due to some stupid gmail
spam policy. Let me try to repost via a different relay. Sorry to those
who have seen the original message and get a duplicate now.

On Wed 21-12-16 08:03:53, Michal Hocko wrote:
> On Tue 20-12-16 14:13:41, Andrew Morton wrote:
> > On Tue, 20 Dec 2016 09:38:22 -0800 Joe Perches <joe@perches.com> wrote:
> > 
> > > > So what are we going to do about this patch?
> > > 
> > > Well if Andrew doesn't object again, it should probably be applied.
> > > Unless his silence here acts like a pocket-veto.
> > > 
> > > Andrew?  Anything to add?
> > 
> > I guess we should give in to reality and do this, or something like it.
> > But Al said he was going to dig out some patches for us to consider?
> 
> Al wanted to cover vmalloc GFP_NOFS context _inside_ the vmalloc
> code.  This is mostly orthogonal to this patch I believe. Besides
> that I _think_ that it would be better to convert those vmalloc(NOFS)
> users to the scope api rather than tweak the vmalloc. One reason to go
> that way is that those vmalloc(NOFS) users need to be checked anyway
> and something tells me that some of them can really be changed to
> GFP_KERNEL.
> 
> This helper is clear about its gfp mask expectation and complain loudly
> if somebody wants something unexpected which is a good start I believe.
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
