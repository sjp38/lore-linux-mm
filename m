Date: Tue, 7 Aug 2001 12:51:05 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <Pine.LNX.4.31.0108070920440.31117-100000@cesium.transmeta.com>
Message-ID: <Pine.LNX.4.33.0108071245250.30280-100000@touchme.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Aug 2001, Linus Torvalds wrote:

> Try pre4.

It's similarly awful (what did you expect -- there are no meaningful
changes between the two!).  io throughput to a 12 disk array is humming
along at a whopping 40MB/s (can do 80) that's very spotty and jerky,
mostly being driven by syncs.  vmscan gets delayed occasionally, and small
interactive program loading varies from not to long (3s) to way too long
(> 30s).

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
