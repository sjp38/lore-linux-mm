Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 581DC38C12
	for <linux-mm@kvack.org>; Tue,  7 Aug 2001 14:11:47 -0300 (EST)
Date: Tue, 7 Aug 2001 14:11:46 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <Pine.LNX.4.31.0108070932400.31167-100000@cesium.transmeta.com>
Message-ID: <Pine.LNX.4.33L.0108071409540.1439-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ben LaHaise <bcrl@redhat.com>, Daniel Phillips <phillips@bonn-fries.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Aug 2001, Linus Torvalds wrote:

> So I _think_ that what happens is:
>  - alloc_pages() itself isn't making any progress, because it's called
>    with GFP_NOFS and thus cannot touch a lot of the pages.
>  - we wake up kswapd to try to help, but kswapd doesn't do anything
>    because it thinks things are fine.

Obvious, you introduced this when you decided to put
the following two things into the kernel:

1) lazy queue movement, when an inactive page gets
   touched we don't move it to the active list
   immediately
2) Daniel Phillips's use-once optimisations, all
   new pages start on the inactive_dirty list

The combination of these two makes for a hell of a
lot of unfreeable pages on the inactive lists and
can effectively disable kreclaimd.

regards,

Rik
--
Executive summary of a recent Microsoft press release:
   "we are concerned about the GNU General Public License (GPL)"


		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
