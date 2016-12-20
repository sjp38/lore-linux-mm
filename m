Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8C66B033B
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 12:38:29 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id o141so115957558itc.1
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 09:38:29 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0230.hostedemail.com. [216.40.44.230])
        by mx.google.com with ESMTPS id 89si7044072iom.26.2016.12.20.09.38.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 09:38:28 -0800 (PST)
Message-ID: <1482255502.1984.21.camel@perches.com>
Subject: Re: [RFC PATCH] mm: introduce kv[mz]alloc helpers
From: Joe Perches <joe@perches.com>
Date: Tue, 20 Dec 2016 09:38:22 -0800
In-Reply-To: <20161220135016.GH3769@dhcp22.suse.cz>
References: <20161208103300.23217-1-mhocko@kernel.org>
	 <20161213101451.GB10492@dhcp22.suse.cz>
	 <1481666853.29291.33.camel@perches.com>
	 <20161214085916.GB25573@dhcp22.suse.cz>
	 <20161220135016.GH3769@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, LKML <linux-kernel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>, kvm@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org, Dave Chinner <david@fromorbit.com>, Al Viro <viro@zeniv.linux.org.uk>, Mikulas Patocka <mpatocka@redhat.com>

On Tue, 2016-12-20 at 14:50 +0100, Michal Hocko wrote:
> On Wed 14-12-16 09:59:16, Michal Hocko wrote:
> > On Tue 13-12-16 14:07:33, Joe Perches wrote:
> > > On Tue, 2016-12-13 at 11:14 +0100, Michal Hocko wrote:
> > > > Are there any more comments or objections to this patch? Is this a good
> > > > start or kv[mz]alloc has to provide a way to cover GFP_NOFS users as
> > > > well in the initial version.
> > > 
> > > Did Andrew Morton ever comment on this?
> > > I believe he was the primary objector in the past.
> > > 
> > > Last I recollect was over a year ago:
> > > 
> > > https://lkml.org/lkml/2015/7/7/1050
> > 
> > Let me quote:
> > : Sigh.  We've resisted doing this because vmalloc() is somewhat of a bad
> > : thing, and we don't want to make it easy for people to do bad things.
> > : 
> > : And vmalloc is bad because a) it's slow and b) it does GFP_KERNEL
> > : allocations for page tables and c) it is susceptible to arena
> > : fragmentation.
> > : 
> > : We'd prefer that people fix their junk so it doesn't depend upon large
> > : contiguous allocations.  This isn't userspace - kernel space is hostile
> > : and kernel code should be robust.
> > : 
> > : So I dunno.  Should we continue to make it a bit more awkward to use
> > : vmalloc()?  Probably that tactic isn't being very successful - people
> > : will just go ahead and open-code it.  And given the surprising amount
> > : of stuff you've placed in kvmalloc_node(), they'll implement it
> > : incorrectly...
> > : 
> > : How about we compromise: add kvmalloc_node(), but include a BUG_ON("you
> > : suck") to it?
> > 
> > While I agree with some of those points, the reality really sucks,
> > though. We have tried the same tactic with __GFP_NOFAIL and failed as
> > well. I guess we should just bite the bullet and provide an api which is
> > so common that people keep reinventing their own ways around that, many
> > times wrongly or suboptimally. BUG_ON("you suck") is just not going to
> > help much I am afraid.
> > 
> > What do you think Andrew?
> 
> So what are we going to do about this patch?

Well if Andrew doesn't object again, it should probably be applied.
Unless his silence here acts like a pocket-veto.

Andrew?  Anything to add?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
