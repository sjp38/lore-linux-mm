Date: Tue, 07 Aug 2001 13:26:30 -0400
From: Chris Mason <mason@suse.com>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
Message-ID: <292520000.997205190@tiny>
In-Reply-To: <Pine.LNX.4.31.0108070932400.31167-100000@cesium.transmeta.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, Ben LaHaise <bcrl@redhat.com>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tuesday, August 07, 2001 10:04:05 AM -0700 Linus Torvalds
<torvalds@transmeta.com> wrote:

> On Tue, 7 Aug 2001, Linus Torvalds wrote:
>> 
>> Sorry, I should have warned people: pre5 is a test-release that was
>> intended solely for Leonard Zubkoff who has been helping with trying to
>> debug a FS livelock condition.
> 
> So I _think_ that what happens is:
>  - alloc_pages() itself isn't making any progress, because it's called
>    with GFP_NOFS and thus cannot touch a lot of the pages.
>  - we wake up kswapd to try to help, but kswapd doesn't do anything
>    because it thinks things are fine.

Which filesystem?  If its one of the journaled ones, other processes might
be waiting on the log trying to flush things out.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
