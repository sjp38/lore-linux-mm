Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 036EE6B0261
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 01:38:11 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m203so3135486wma.2
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 22:38:10 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id k129si16629619wmb.68.2016.12.08.22.38.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 22:38:08 -0800 (PST)
Date: Fri, 9 Dec 2016 06:38:04 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC PATCH] mm: introduce kv[mz]alloc helpers
Message-ID: <20161209063803.GY1555@ZenIV.linux.org.uk>
References: <20161208103300.23217-1-mhocko@kernel.org>
 <20161209014417.GN4326@dastard>
 <20161209020016.GX1555@ZenIV.linux.org.uk>
 <20161209062224.GB12012@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161209062224.GB12012@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, LKML <linux-kernel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>, kvm@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org

On Fri, Dec 09, 2016 at 07:22:25AM +0100, Michal Hocko wrote:

> > Easier to handle those in vmalloc() itself.
> 
> I think there were some attempts in the past but some of the code paths
> are burried too deep and adding gfp_mask all the way down there seemed
> like a major surgery.

No need to propagate gfp_mask - the same trick XFS is doing right now can
be done in vmalloc.c in a couple of places and that's it; I'll resurrect the
patches and post them tomorrow after I get some sleep.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
