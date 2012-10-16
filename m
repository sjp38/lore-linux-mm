Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id A54526B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 09:12:33 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so6686533pad.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 06:12:33 -0700 (PDT)
Date: Tue, 16 Oct 2012 22:12:28 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: compaction: Correct the nr_strict_isolated check for
 CMA
Message-ID: <20121016131228.GB5603@barrios>
References: <20121016083927.GG29125@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121016083927.GG29125@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Arm Kernel Mailing List <linux-arm-kernel@lists.infradead.org>

On Tue, Oct 16, 2012 at 09:39:27AM +0100, Mel Gorman wrote:
> Thierry reported that the "iron out" patch for isolate_freepages_block()
> had problems due to the strict check being too strict with "mm: compaction:
> Iron out isolate_freepages_block() and isolate_freepages_range() -fix1".
> It's possible that more pages than necessary are isolated but the check
> still fails and I missed that this fix was not picked up before RC1. This
> same problem has been identified in 3.7-RC1 by Tony Prisk and should be
> addressed by the following patch.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Tested-by: Tony Prisk <linux@prisktech.co.nz>
Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind Regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
