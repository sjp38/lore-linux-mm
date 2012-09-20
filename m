Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 15CCE6B0069
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 14:54:38 -0400 (EDT)
Message-ID: <505B6669.2040104@redhat.com>
Date: Thu, 20 Sep 2012 14:54:33 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/6] mm: compaction: Acquire the zone->lock as late as
 possible
References: <1348149875-29678-1-git-send-email-mgorman@suse.de> <1348149875-29678-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1348149875-29678-4-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 09/20/2012 10:04 AM, Mel Gorman wrote:
> Compactions free scanner acquires the zone->lock when checking for PageBuddy
> pages and isolating them. It does this even if there are no PageBuddy pages
> in the range.
>
> This patch defers acquiring the zone lock for as long as possible. In the
> event there are no free pages in the pageblock then the lock will not be
> acquired at all which reduces contention on zone->lock.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
