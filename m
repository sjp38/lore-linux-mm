Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9CA9000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 13:00:03 -0400 (EDT)
Date: Mon, 20 Jun 2011 17:59:55 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/3] mm: make the threshold of enabling THP configurable
Message-ID: <20110620165955.GB9396@suse.de>
References: <1308587683-2555-1-git-send-email-amwang@redhat.com>
 <1308587683-2555-2-git-send-email-amwang@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1308587683-2555-2-git-send-email-amwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Tue, Jun 21, 2011 at 12:34:29AM +0800, Amerigo Wang wrote:
> Don't hard-code 512M as the threshold in kernel, make it configruable,
> and set 512M by default.
> 

I'm not seeing the gain here either. This is something that is going to
be set by distributions and probably never by users. If the default of
512 is incorrect, what should it be? Also, the Kconfig help message has
spelling errors.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
