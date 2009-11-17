Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3223C6B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 17:11:46 -0500 (EST)
Date: Wed, 18 Nov 2009 09:11:08 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 7/7] xfs: Don't use PF_MEMALLOC
Message-ID: <20091117221108.GK9467@discord.disaster>
References: <20091117161551.3DD4.A69D9226@jp.fujitsu.com> <20091117162235.3DEB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20091117162235.3DEB.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, xfs-masters@oss.sgi.com, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, Nov 17, 2009 at 04:23:43PM +0900, KOSAKI Motohiro wrote:
> 
> Non MM subsystem must not use PF_MEMALLOC. Memory reclaim need few
> memory, anyone must not prevent it. Otherwise the system cause
> mysterious hang-up and/or OOM Killer invokation.

The xfsbufd is a woken run by a registered memory shaker. i.e. it
runs when the system needs to reclaim memory. It forceN? the
delayed write metadata buffers (of which there can be a lot) to disk
so that they can be reclaimed on IO completion. This IO submission
may require N?ome memory to be allocated to be able to free that
memory.

Hence, AFAICT the use of PF_MEMALLOC is valid here.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
