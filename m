Date: Tue, 07 Aug 2001 16:22:51 -0400
From: Chris Mason <mason@suse.com>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
Message-ID: <493160000.997215771@tiny>
In-Reply-To: <Pine.LNX.4.33.0108071251100.3977-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tuesday, August 07, 2001 12:52:11 PM -0700 Linus Torvalds
<torvalds@transmeta.com> wrote:

> On Tue, 7 Aug 2001, Chris Mason wrote:
>> 
>> Linus seemed pretty sure kswapd wasn't deadlocked, but though I would
>> mention this anyway....
> 
> The thing that Leonard seems able to repeat pretty well is just doing a
> "mke2fs" on a big partition. I don't think xfs is involved there at all.

It depends, mke2fs could be just another GFP_NOFS process waiting around
for kswapd to free buffers.  If a journaled filesystem is there, and it is
locking up kswapd, any heavy buffer allocator could make the problem seem
worse.

But, if you mean XFS is not mounted at all, I'm way off ;-)

-chris




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
