Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 68DBE6B0055
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 17:11:00 -0400 (EDT)
Date: Thu, 6 Aug 2009 17:09:55 -0400
From: Jeff Dike <jdike@addtoit.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <20090806210955.GA14201@c2.user-mode-linux.org>
References: <20090805024058.GA8886@localhost> <20090805155805.GC23385@random.random> <20090806100824.GO23385@random.random> <4A7AAE07.1010202@redhat.com> <20090806102057.GQ23385@random.random> <20090806105932.GA1569@localhost> <4A7AC201.4010202@redhat.com> <20090806130631.GB6162@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090806130631.GB6162@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Side question -
	Is there a good reason for this to be in shrink_active_list()
as opposed to __isolate_lru_page?

		if (unlikely(!page_evictable(page, NULL))) {
			putback_lru_page(page);
			continue;
		}

Maybe we want to minimize the amount of code under the lru lock or
avoid duplicate logic in the isolate_page functions.

But if there are important mlock-heavy workloads, this could make the
scan come up empty, or at least emptier than we might like.

				Jeff

-- 
Work email - jdike at linux dot intel dot com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
