Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id CF6726B0068
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 14:54:07 -0400 (EDT)
Message-ID: <505B6647.1080005@redhat.com>
Date: Thu, 20 Sep 2012 14:53:59 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] mm: compaction: Abort compaction loop if lock is
 contended or run too long
References: <1348149875-29678-1-git-send-email-mgorman@suse.de> <1348149875-29678-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1348149875-29678-2-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 09/20/2012 10:04 AM, Mel Gorman wrote:
> From: Shaohua Li <shli@fusionio.com>
>
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
>
> [minchan@kernel.org: Putback pages isolated for migration if aborting]
> [akpm@linux-foundation.org: compact_zone_order requires non-NULL arg contended]
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Shaohua Li <shli@fusionio.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
