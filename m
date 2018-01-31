Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id B05C96B0006
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 18:42:42 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id s9so16026379ioa.20
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 15:42:42 -0800 (PST)
Received: from resqmta-po-11v.sys.comcast.net (resqmta-po-11v.sys.comcast.net. [2001:558:fe16:19:96:114:154:170])
        by mx.google.com with ESMTPS id d5si603363ioj.147.2018.01.31.15.42.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 15:42:41 -0800 (PST)
Date: Wed, 31 Jan 2018 17:42:40 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: [LSF/MM ATTEND] Large memory issues, new fragmentation avoidance
 scheme
Message-ID: <alpine.DEB.2.20.1801311730400.21179@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org

Would like to attend the upcoming summit and would be interested in
participating in the large memory discussions (including NVRAM, DAX) as
well as improvements in huge page support (pagecache, easy
configurability, consistency over multiple sizes of huge pages etc  etc)

Also an important subject matter would be to investigate ways to improve
I/O throughput from memory for large scale datasets (1TB or higher). Maybe
this straddles a bit into the FS part too.

Recently stumbled over another way to avoid fragmentation by reserving
certain numbers of sizes of each page order. This seems to be deployed at
a large ISP for years now and working out ok. Maybe another stab at the
problem of availability of higher. Would like to discuss if this approach
could be upstreamed.

Then I'd like to continue explore ways to avoid fragmentation like movable
objects in slab caches (see the xarray implementation for example).
Coming up with an inode/dentry targeted reclaim/move approach would also
be interesting in particular since these already have _isolate_ functions
and are akin to the early steps in page migration where the focused on
targeted reclaim (and then reloading the page from swap) to simplify the
approach rather than making page actually movable.

There are numerous other issues with large memory and throughput of
extreme HPC loads that my coworkers are currently running into. Would be
good to share experiences and figure out ways to address these.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
