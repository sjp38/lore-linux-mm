Subject: Re: reduce shrink_mmap rate of failure (initial attempt)
References: <393D8E26.E51525CB@norran.net>
From: "Quintela Carreira Juan J." <quintela@fi.udc.es>
In-Reply-To: Roger Larsson's message of "Wed, 07 Jun 2000 01:49:58 +0200"
Date: 07 Jun 2000 05:01:37 +0200
Message-ID: <ytt3dmqfb3i.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: Alan Cox <alan@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Zlatko Calusic <zlatko@iskon.hr>
List-ID: <linux-mm.kvack.org>

>>>>> "roger" == Roger Larsson <roger.larsson@norran.net> writes:

Hi

roger> This is a trivial first attempt to reduce shrink_mmap failures
roger> (leading to swap)

roger> It is against 2.4.0-test1-ac7-riel3 but that is almost what
roger> we have currently - and it is trivial to apply with an editor.

roger> It might be possible to improve this further - but it is a start.

That patch hangs my machine here when I run mmap002.  The machine is
in shrink_mmap.  It hangs trying to get the pagmap_lru_lock.

I think that the idea is good, but it doesn't work here :(.

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
