Subject: Re: reduce shrink_mmap rate of failure (initial attempt)
References: <393D8E26.E51525CB@norran.net>
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 07 Jun 2000 15:22:29 +0200
Message-ID: <dnbt1dzkve.fsf@magla.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: Alan Cox <alan@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Roger Larsson <roger.larsson@norran.net> writes:

> Hi all,
> 
> This is a trivial first attempt to reduce shrink_mmap failures
> (leading to swap)
> 
> It is against 2.4.0-test1-ac7-riel3 but that is almost what
> we have currently - and it is trivial to apply with an editor.
> 
> It might be possible to improve this further - but it is a start.
> (Time for bed...)
> 

Very nice idea, but...

I tried exactly that a week or two ago and it was freezing the system
like Juan noted (under heavy I/O loads). That's very unfortunate
because it is my opinion too that shrink_mmap() fails too easily and
falls back to swapping when it really shouldn't do that.

Regards,
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
