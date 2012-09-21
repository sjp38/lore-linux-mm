Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 2E0E16B0044
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 17:31:24 -0400 (EDT)
Date: Fri, 21 Sep 2012 14:31:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/9] mm: compaction: Abort compaction loop if lock is
 contended or run too long
Message-Id: <20120921143122.5be94b28.akpm@linux-foundation.org>
In-Reply-To: <1348224383-1499-5-git-send-email-mgorman@suse.de>
References: <1348224383-1499-1-git-send-email-mgorman@suse.de>
	<1348224383-1499-5-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 21 Sep 2012 11:46:18 +0100
Mel Gorman <mgorman@suse.de> wrote:

> Changelog since V2
> o Fix BUG_ON triggered due to pages left on cc.migratepages
> o Make compact_zone_order() require non-NULL arg `contended'
> 
> Changelog since V1
> o only abort the compaction if lock is contended or run too long
> o Rearranged the code by Andrea Arcangeli.
> 
> isolate_migratepages_range() might isolate no pages if for example when
> zone->lru_lock is contended and running asynchronous compaction. In this
> case, we should abort compaction, otherwise, compact_zone will run a
> useless loop and make zone->lru_lock is even contended.

hm, this appears to be identical to

mm-compaction-abort-compaction-loop-if-lock-is-contended-or-run-too-long.patch
mm-compaction-abort-compaction-loop-if-lock-is-contended-or-run-too-long-fix.patch
mm-compaction-abort-compaction-loop-if-lock-is-contended-or-run-too-long-fix-2.patch

so I simply omitted patches 2, 3 and 4.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
