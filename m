Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on 2.4.0-test2
References: <Pine.LNX.4.21.0007111756200.3644-100000@inspiron.random>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Andrea Arcangeli's message of "Tue, 11 Jul 2000 18:17:25 +0200 (CEST)"
Date: 11 Jul 2000 18:36:56 +0200
Message-ID: <yttn1jomxnb.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

>>>>> "andrea" == Andrea Arcangeli <andrea@suse.de> writes:

andrea> On Tue, 11 Jul 2000, Stephen C. Tweedie wrote:
>> Hi,
>> 
>> On Sun, Jul 09, 2000 at 10:31:46PM +0200, Andrea Arcangeli wrote:
>>> 
>>> Think what happens if we shrink lru_mapped first.
>> 
>> It's not supposed to work that way.

andrea> The object of this simple example is to show that the lrus have different
andrea> priorities. These priorities will probably change in function of the
andrea> workload of course but we can try to take care of that.

I agree with Stephen here, if my cache page is older than my mmaped vi
page, I want to unmap first the vi page.

andrea> I see what you plan to do. Fact is that I'm not convinced it's necessary
andrea> and I prefer to have a dynamic falling back algorithms between caches that
andrea> will avoid me to have additional lru lists and additional refile between
andrea> lrus. Also I will be able to say when I did progress because my progress
andrea> will _always_ correspond to a page freed (so I'll remove the unrobusteness
andrea> of the current swap_out completly).

Yes, but you have to find a _magic_ number for knowing when to free
for the maped pages/cache pages.  That number comes for free with the
inactive list implementation and is based in the actual workload,
i.e. we don't need to guess.

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
