Date: Tue, 11 Jul 2000 20:00:23 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
 2.4.0-test2
In-Reply-To: <Pine.LNX.4.21.0007111445280.10961-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0007111955100.5098-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Jul 2000, Rik van Riel wrote:

>On Tue, 11 Jul 2000, Andrea Arcangeli wrote:
>> On Tue, 11 Jul 2000, Rik van Riel wrote:
>> 
>> >No. You just wrote down the strongest argument in favour of one
>> >unified queue for all types of memory usage.
>> 
>> Do that and download an dozen of iso image with gigabit ethernet
>> in background.
>
>You need to forget about LRU for a moment. The fact that
>LRU is fundamentally broken doesn't mean that it has
>anything whatsoever to do with whether we age all pages
>fairly or whether we prefer some pages over other pages.
>
>If LRU is broken we need to fix that, a workaround like
>your proposal doesn't fix anything in this case.

So tell me how with your design can I avoid the kernel to unmap anything
while running:

	cp /dev/zero .

forever.

Whatever aging algorithm you use if you wait enough time the mapped pages
will be thrown away eventually.

If the above `cp` is able to throw away _everything_ eventually, that will
be a major problem IMHO and I don't agree in using a long-term-design that
can't avoid that so common problem.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
