Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA25430
	for <linux-mm@kvack.org>; Tue, 1 Dec 1998 11:24:55 -0500
Date: Tue, 1 Dec 1998 17:12:45 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: swapin readahead and locking
Message-ID: <Pine.LNX.3.96.981201170845.437E-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Stephen,

I am now using the following construction (well, since
09:15 this morning):

struct page *page_map = lookup_swap_cache(entry);

if (!page_map) {
	page_map = read_swap_cache(entry);

... do readahead stuff
}

I have a funny feeling I missed a wait_on_page() this way,
but things are runnig happily right now. If I missed a big
thing like this, please let me know -- I'd hate it to have
people test the patch (it is up for grabs) and end up with
a corrupted system...

thanks,

Rik -- now completely used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
