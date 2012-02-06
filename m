Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id C945D6B13F0
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 15:50:04 -0500 (EST)
Date: Mon, 6 Feb 2012 12:49:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] compact_pgdat: workaround lockdep warning in kswapd
Message-Id: <20120206124952.75702d5c.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1202061129040.2144@eggly.anvils>
References: <alpine.LSU.2.00.1202061129040.2144@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org

On Mon, 6 Feb 2012 11:40:08 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> I get this lockdep warning from swapping load on linux-next
> (20120201 but I expect the same from more recent days):

The patch looks good as a standalone optimisation/cleanup.  The lack of
clarity on the lockdep thing is a concern - I have a feeling we'll be
bitten again.

This fix seems to be applicable to mainline?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
