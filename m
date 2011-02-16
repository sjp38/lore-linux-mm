Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E8B428D003B
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 14:08:10 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] - Improve drain pages performance on large systems
References: <20110215223840.GA27420@sgi.com>
Date: Tue, 15 Feb 2011 16:17:44 -0800
In-Reply-To: <20110215223840.GA27420@sgi.com> (Jack Steiner's message of "Tue,
	15 Feb 2011 16:38:40 -0600")
Message-ID: <m262skx26v.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Jack Steiner <steiner@sgi.com> writes:

> Heavy swapping within a cpuset causes frequent calls to drain_all_pages().

I suspect drain_all_pages should be really made more zone aware in the
first place and only drain what is actually needed (e.g.
work off a zonelist). I was fighting with this for hwpoison too.

That said your patch looks reasonable.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
