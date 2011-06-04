Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DA1086B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 20:25:58 -0400 (EDT)
Date: Sat, 4 Jun 2011 01:25:52 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 06/12] inode: Make unused inode LRU per superblock
Message-ID: <20110604002552.GU11521@ZenIV.linux.org.uk>
References: <1306998067-27659-1-git-send-email-david@fromorbit.com>
 <1306998067-27659-7-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1306998067-27659-7-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

On Thu, Jun 02, 2011 at 05:01:01PM +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> The inode unused list is currently a global LRU. This does not match
> the other global filesystem cache - the dentry cache - which uses
> per-superblock LRU lists. Hence we have related filesystem object
> types using different LRU reclaimation schemes.
> 
> To enable a per-superblock filesystem cache shrinker, both of these
> caches need to have per-sb unused object LRU lists. Hence this patch
> converts the global inode LRU to per-sb LRUs.
> 
> The patch only does rudimentary per-sb propotioning in the shrinker
> infrastructure, as this gets removed when the per-sb shrinker
> callouts are introduced later on.

What protects s_nr_inodes_unused?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
