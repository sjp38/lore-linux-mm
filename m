Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on 2.4.0-test2
References: <Pine.LNX.4.21.0007111938241.3644-100000@inspiron.random>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Andrea Arcangeli's message of "Tue, 11 Jul 2000 19:41:27 +0200 (CEST)"
Date: 11 Jul 2000 20:13:42 +0200
Message-ID: <ytt8zv8mt61.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

>>>>> "andrea" == Andrea Arcangeli <andrea@suse.de> writes:

andrea> On Tue, 11 Jul 2000, Rik van Riel wrote:
>> No. You just wrote down the strongest argument in favour of one
>> unified queue for all types of memory usage.

andrea> Do that and download an dozen of iso image with gigabit ethernet in
andrea> background.

With Gigabit etherenet, the pages that you are coping will never be
touched again -> that means that its age will never will increase,
that means that it will only remove pages from the cache that are
younger/have been a lot of time without being used.  That looks quite
ok to me.  Notice that the fact that the pages came from the Gigabit
ethernet makes no diference that if you copy from other medium.  Only
difference is that you will get them only faster.

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
