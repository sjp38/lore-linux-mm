From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14301.15666.461081.663416@dukat.scot.redhat.com>
Date: Mon, 13 Sep 1999 19:06:42 +0100 (BST)
Subject: Re: [2.2.12 PATCH] Re: bdflush defaults bugreport
In-Reply-To: <Pine.LNX.3.96.990905043424.27200B-100000@mole.spellcast.com>
References: <Pine.LNX.4.10.9909050953540.247-100000@mirkwood.dummy.home>
	<Pine.LNX.3.96.990905043424.27200B-100000@mole.spellcast.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: Rik van Riel <riel@humbolt.geo.uu.nl>, Linux MM <linux-mm@kvack.org>, alan@redhat.com
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 5 Sep 1999 04:55:41 -0400 (EDT), "Benjamin C.R. LaHaise"
<blah@kvack.org> said:

> I don't quite think that changing the percentage dirty is the right thing
> in this case.  Rather, the semantics of refile_buffer / wakeup_bdflush /
> mark_buffer_clean need to be tweaked: as it stands, bdflush will wake
> bdflush_done before the percentage of dirty buffers drops below the
> threshhold.  The right fix should be to move the wake_up into the if
> checking the threshhold right below it as the only user of bdflush_done is
> from wake_bdflush when too many buffers are dirty.  Patch below (albeit
> untested).  Alan/Stephen: comments?

It shouldn't have any noticeable effect: all that would happen with that
patch applied is that the woken process would wake early, write one more
buffer and drop straight back into the wakeup_bdflush(1) stall.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
