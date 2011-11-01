Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C39736B0069
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 11:06:20 -0400 (EDT)
Date: Tue, 1 Nov 2011 16:05:55 +0100
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH] fadvise: only initiate writeback for specified range
 with FADV_DONTNEED
Message-ID: <20111101150555.GC19965@redhat.com>
References: <1320077819-1494-1-git-send-email-sbohrer@rgmadvisors.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1320077819-1494-1-git-send-email-sbohrer@rgmadvisors.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Oct 31, 2011 at 11:16:59AM -0500, Shawn Bohrer wrote:
> Previously POSIX_FADV_DONTNEED would start writeback for the entire file
> when the bdi was not write congested.  This negatively impacts
> performance if the file contians dirty pages outside of the requested
> range.  This change uses __filemap_fdatawrite_range() to only initiate
> writeback for the requested range.
> 
> Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>

It probably makes sense for some cases to take advantage of the disk
head being nearby and flush more than requested.

But I can certainly see this go wrong by taking away the write-caching
benefits for the rest of the file just because a small part of it was
fadvised.

Acked-by: Johannes Weiner <jweiner@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
