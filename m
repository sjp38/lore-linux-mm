Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B34A6B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 13:12:36 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c85so53435144wmi.6
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 10:12:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l66si78606282wml.44.2017.01.04.10.12.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Jan 2017 10:12:35 -0800 (PST)
Date: Wed, 4 Jan 2017 19:12:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm: support __GFP_REPEAT in kvmalloc_node
Message-ID: <20170104181229.GB10183@dhcp22.suse.cz>
References: <20170102133700.1734-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170102133700.1734-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, kvm@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org, linux-ext4@vger.kernel.org, Joe Perches <joe@perches.com>, Anatoly Stepanov <astepanov@cloudlinux.com>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger@dilger.ca>

While checking opencoded users I've encountered that vhost code would
really like to use kvmalloc with __GFP_REPEAT [1] so the following patch
adds support for __GFP_REPEAT and converts both vhost users.

So currently I am sitting on 3 patches. I will wait for more feedback -
especially about potential split ups or cleanups few more days and then
repost the whole series.

[1] http://lkml.kernel.org/r/20170104150800.GO25453@dhcp22.suse.cz
---
