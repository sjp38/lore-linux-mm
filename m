Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 12BF56B004F
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 17:16:53 -0500 (EST)
Date: Tue, 10 Feb 2009 14:16:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] vmscan: initialize sc->nr_reclaimed in
 do_try_to_free_pages()
Message-Id: <20090210141613.276a3c9c.akpm@linux-foundation.org>
In-Reply-To: <20090209222416.GA9758@cmpxchg.org>
References: <20090209222416.GA9758@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: riel@redhat.com, wli@movementarian.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Feb 2009 23:24:16 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> The commit missed to actually adjust do_try_to_free_pages() which now
> does not initialize sc.nr_reclaimed and makes shrink_zone() make
> assumptions on whether to bail out of the reclaim cycle based on an
> uninitialized value.

Both callers of do_try_to_free_pages() _do_ initialise
scan_control.nr_reclaimed.  The unitemised fields in a struct
initaliser are reliably zeroed.

We often rely upon this, and the only reason for mentioning such a
field is for documentation reasons, or if you want to add a comment at
the initialisation site.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
