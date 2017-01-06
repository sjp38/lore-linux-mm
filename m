Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 350416B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 08:35:03 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id k184so3494354wme.4
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 05:35:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o7si89230584wjw.219.2017.01.06.05.35.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 05:35:02 -0800 (PST)
Date: Fri, 6 Jan 2017 14:34:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: introduce kv[mz]alloc helpers
Message-ID: <20170106133459.GM5556@dhcp22.suse.cz>
References: <20170102133700.1734-1-mhocko@kernel.org>
 <747f7b9a-e95d-a872-7e30-ea235b91593a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <747f7b9a-e95d-a872-7e30-ea235b91593a@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, kvm@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org, linux-ext4@vger.kernel.org, Joe Perches <joe@perches.com>, Anatoly Stepanov <astepanov@cloudlinux.com>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger@dilger.ca>

On Fri 06-01-17 14:29:33, Vlastimil Babka wrote:
> On 01/02/2017 02:37 PM, Michal Hocko wrote:
> > --- a/drivers/vhost/vhost.c
> > +++ b/drivers/vhost/vhost.c
> > @@ -514,18 +514,9 @@ long vhost_dev_set_owner(struct vhost_dev *dev)
> >  }
> >  EXPORT_SYMBOL_GPL(vhost_dev_set_owner);
> >  
> > -static void *vhost_kvzalloc(unsigned long size)
> > -{
> > -	void *n = kzalloc(size, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
> 
> Hi, I just noticed that this had __GFP_REPEAT, so you'll probably want
> to move these hunks to patch 3 with the rest of vhost.

Well, spotted. I will do that. Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
