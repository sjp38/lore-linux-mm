Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id A2BDD6B0032
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 04:56:45 -0400 (EDT)
Message-ID: <51B1A04B.7030003@yandex-team.ru>
Date: Fri, 07 Jun 2013 12:56:43 +0400
From: Roman Gushchin <klamm@yandex-team.ru>
MIME-Version: 1.0
Subject: slub: slab order on multi-processor machines
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, yanmin.zhang@intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi!

While investigating some compaction-related problems, I noticed, that many (even most)
kernel objects are allocated on slabs with order 2 or 3.

This behavior was introduced by commit 9b2cd506e "slub: Calculate min_objects based on
number of processors." by Christoph Lameter.
As I understand, the idea was to make kernel allocations cheaper by reducing the total
number of page allocations (allocating 1 page with order 3 is cheaper than allocating
8 1-ordered pages).

I'm sure, it's true for recently rebooted machine with a lot of free non-fragmented memory.
But is it also true for heavy-loaded machine with fragmented memory?
Are we sure, that it's cheaper to run compaction and allocate order 3 page than to use
small 1-pages slabs?
Do I miss something?

Disabling this behavior dramatically reduces the number of 2- and 3-ordered allocations.
Compaction is performed significantly rarer. This is especially noticeable on machines
with intensive disk i/o. I do not see any performance degradation. But I'm not sure,
that I'm not missing something.

Any comments and/or ideas are welcomed.

Thanks!

Regards,
Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
