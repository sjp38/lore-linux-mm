Date: Tue, 7 Aug 2001 12:52:11 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <359550000.997209619@tiny>
Message-ID: <Pine.LNX.4.33.0108071251100.3977-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <mason@suse.com>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Aug 2001, Chris Mason wrote:
>
> Linus seemed pretty sure kswapd wasn't deadlocked, but though I would
> mention this anyway....

The thing that Leonard seems able to repeat pretty well is just doing a
"mke2fs" on a big partition. I don't think xfs is involved there at all.

	Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
