Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A66398D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 18:46:49 -0400 (EDT)
Date: Mon, 14 Mar 2011 18:46:45 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: ext4 deep stack with mark_page_dirty reclaim
Message-ID: <20110314224645.GA20348@infradead.org>
References: <alpine.LSU.2.00.1103141156190.3220@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1103141156190.3220@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Direct reclaim (in the cgroup variant) at it's work.  We had a couple of
flamewars on this before, but this trivial example with reclaim from
the most simple case (swap space) shows that we really should never
reclaim from memory allocation callers for stack usage reasons.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
