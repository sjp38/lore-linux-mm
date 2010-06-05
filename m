Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9E0A26B01AD
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 21:15:04 -0400 (EDT)
Date: Sat, 5 Jun 2010 11:14:47 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 0/2 RFC v3] Livelock avoidance for data integrity
 writeback
Message-ID: <20100605011447.GF26335@laptop>
References: <1275677231-15662-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1275677231-15662-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, david@fromorbit.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 04, 2010 at 08:47:09PM +0200, Jan Kara wrote:
> 
>   Hi,
> 
>   I've revived my patches to implement livelock avoidance for data integrity
> writes. Due to some concerns whether tagging of pages before writeout cannot
> be too costly to use for WB_SYNC_NONE mode (where we stop after nr_to_write
> pages) I've changed the patch to use page tagging only in WB_SYNC_ALL mode
> where we are sure that we write out all the tagged pages. Later, we can think
> about using tagging for livelock avoidance for WB_SYNC_NONE mode as well...

Hmm what concerns? Do you have any numbers?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
