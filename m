Date: Wed, 3 Nov 1999 15:29:35 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: Why don't we make mmap MAP_SHARED with /dev/zero possible?
In-Reply-To: <qwwzox6l3nh.fsf@sap.com>
Message-ID: <Pine.LNX.4.10.9911031527070.6110-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <hans-christoph.rohland@sap.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, fxzhang@chpc.ict.ac.cn, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 26 Oct 1999, Christoph Rohland wrote:

> This lines up with some remarks from Eric Biederman about his shmfs,
> which is BTW a feature I would _love_ to have in Linux to do posix shm
> and perhaps redo sysv shm. He said that he would like to make the
> pagecache highmem-capable and AFAIK the main work for shmfs was
> makeing the pagecache working with writeable pages.

hm, i've got the pagecache in high memory already on my box, patch under
cleanup right now. It was the next natural step after doing all the hard
work to get 64GB RAM support. Eric, is there any conflicting work here?

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
