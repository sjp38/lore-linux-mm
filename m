Date: Mon, 29 Jul 2002 00:05:07 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] start_aggressive_readahead
In-Reply-To: <95C024B4-A298-11D6-A4C0-000393829FA4@cs.amherst.edu>
Message-ID: <Pine.LNX.4.44L.0207282355130.3086-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Scott Kaplan <sfkaplan@cs.amherst.edu>
Cc: Andrew Morton <akpm@zip.com.au>, Christoph Hellwig <hch@lst.de>, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 28 Jul 2002, Scott Kaplan wrote:
> On Sunday, July 28, 2002, at 08:19 PM, Rik van Riel wrote:
>
> > I'm not sure about that. If we do linear IO we most likely
> > want to evict the pages we've already used as opposed to the
> > pages we're about to use.
>
> The situation is more subtle than that.

> Consider exactly the case you have raised -- strict, linear referencing of
> blocks, such as a sequential file read.  When block `i' is referenced, it
> is an excellent prediction that block `i+1' will be referenced soon.  If
> block `i+1' is not referenced soon, then the prediction was incorrect,
> *and there's little reason to keep the block around any longer*.

My experience with 300 ftp clients pulling a collective 40 Mbit/s
suggests otherwise.

About 70% of the clients were on modem speed and the other 30% of
the clients were on widely variable higher speeds.

Since a disk seek + read is about 10ms, the absolute maximum
number of seeks that can be done is 100 a second and the minimum
amount of time between disk seeks for one stream should be about
3 seconds.

In reality the situation is worse because of the large speed
difference between the disk seeks and the fact that we want a
reasonably low latency for disk IO for the other tasks in the
system.

This would put the conservative minimum time we should keep
readahead data in RAM at something like 10 seconds, to account
for the speed differences of fast and slow data streams and to
not completely bog down the IO subsystem with requests.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
