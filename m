Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on 2.4.0-test2
References: <Pine.LNX.4.21.0007111944450.3644-100000@inspiron.random>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Andrea Arcangeli's message of "Tue, 11 Jul 2000 19:54:31 +0200 (CEST)"
Date: 11 Jul 2000 20:03:41 +0200
Message-ID: <yttem50mtmq.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

>>>>> "andrea" == Andrea Arcangeli <andrea@suse.de> writes:

andrea> On Tue, 11 Jul 2000, Rik van Riel wrote:
>> This is why LRU is wrong and we need page aging (which
>> approximates both LRU and NFU).
>> 
>> The idea is to remove those pages from memory which will
>> not be used again for the longest time, regardless of in
>> which 'state' they live in main memory.
>> 
>> (and proper page aging is a good approximation to this)

andrea> It will still drop _all_ VM mappings from memory if you left "cp /dev/zero
andrea> ." in background for say 2 hours. This in turn mean that during streming
andrea> I/O you'll have _much_ more than the current swapin/swapout troubles.

If you are copying in the background a cp and you don't touch your
vi/emacs/whatever pages in 2 hours (i.e. age = 0) then I think that it
is ok for that pages to be swaped out.  Notice that the cage pages
will have _initial age_  and the pages of the binaries will have an
_older_ age.

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
