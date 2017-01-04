Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 798666B0253
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 09:20:28 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id i131so83997133wmf.3
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 06:20:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pb5si81542729wjb.189.2017.01.04.06.20.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Jan 2017 06:20:27 -0800 (PST)
Date: Wed, 4 Jan 2017 15:20:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: introduce kv[mz]alloc helpers
Message-ID: <20170104142022.GL25453@dhcp22.suse.cz>
References: <20170102133700.1734-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170102133700.1734-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, kvm@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org, linux-ext4@vger.kernel.org, Joe Perches <joe@perches.com>, Anatoly Stepanov <astepanov@cloudlinux.com>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger@dilger.ca>

OK, so I've checked the open coded implementations and converted most of
them. There are few which are either confused and need some special
handling or need double checking.

I can fold this into the original patch or keep it as a separate patch.
Whatever works better for others.
---
