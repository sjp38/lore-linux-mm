Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0296B000D
	for <linux-mm@kvack.org>; Tue, 29 May 2018 07:52:04 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 89-v6so9186041plb.18
        for <linux-mm@kvack.org>; Tue, 29 May 2018 04:52:04 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id q19-v6si4079098pgn.392.2018.05.29.04.52.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 04:52:03 -0700 (PDT)
Date: Tue, 29 May 2018 05:51:58 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH v2] doc: document scope NOFS, NOIO APIs
Message-ID: <20180529055158.0170231e@lwn.net>
In-Reply-To: <20180529082644.26192-1-mhocko@kernel.org>
References: <20180524114341.1101-1-mhocko@kernel.org>
	<20180529082644.26192-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, Randy Dunlap <rdunlap@infradead.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

On Tue, 29 May 2018 10:26:44 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> Although the api is documented in the source code Ted has pointed out
> that there is no mention in the core-api Documentation and there are
> people looking there to find answers how to use a specific API.

So, I still think that this:

> +The traditional way to avoid this deadlock problem is to clear __GFP_FS
> +respectively __GFP_IO (note the latter implies clearing the first as well) in

doesn't read the way you intend it to.  But we've sent you in more
than enough circles on this already, so I went ahead and applied it;
wording can always be tweaked later.

You added the kerneldoc comments, but didn't bring them into your new
document.  I'm going to tack this on afterward, hopefully nobody will
object.

Thanks,

jon

---
docs: Use the kerneldoc comments for memalloc_no*()

Now that we have kerneldoc comments for
memalloc_no{fs,io}_{save_restore}(), go ahead and pull them into the docs.

Signed-off-by: Jonathan Corbet <corbet@lwn.net>
---
 Documentation/core-api/gfp_mask-from-fs-io.rst | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/Documentation/core-api/gfp_mask-from-fs-io.rst b/Documentation/core-api/gfp_mask-from-fs-io.rst
index 2dc442b04a77..e0df8f416582 100644
--- a/Documentation/core-api/gfp_mask-from-fs-io.rst
+++ b/Documentation/core-api/gfp_mask-from-fs-io.rst
@@ -33,6 +33,11 @@ section from a filesystem or I/O point of view. Any allocation from that
 scope will inherently drop __GFP_FS respectively __GFP_IO from the given
 mask so no memory allocation can recurse back in the FS/IO.
 
+.. kernel-doc:: include/linux/sched/mm.h
+   :functions: memalloc_nofs_save memalloc_nofs_restore
+.. kernel-doc:: include/linux/sched/mm.h
+   :functions: memalloc_noio_save memalloc_noio_restore
+
 FS/IO code then simply calls the appropriate save function before
 any critical section with respect to the reclaim is started - e.g.
 lock shared with the reclaim context or when a transaction context
-- 
2.14.3
