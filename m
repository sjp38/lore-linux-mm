Subject: Re: 2.4: why is NR_GFPINDEX so large?
References: <20000621204734Z131177-21003+32@kanga.kvack.org>
	<20000621210620Z131176-21003+33@kanga.kvack.org>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Timur Tabi's message of "Wed, 21 Jun 2000 15:59:51 -0500"
Date: 21 Jun 2000 23:24:06 +0200
Message-ID: <yttvgz2k9s9.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "timur" == Timur Tabi <ttabi@interactivesi.com> writes:

timur> ** Reply to message from Kanoj Sarcar <kanoj@google.engr.sgi.com> on Wed, 21
timur> Jun 2000 13:49:56 -0700 (PDT)


>> Yes, this is saying that although we waste physical memory (which few
>> people care about any more), some of the unused space is never cached,
>> since it is not accessed (although hardware processor prefetches might
>> change this assumption a little bit). So, valuable cache space is not 
>> wasted that can be used to hold data/code that is actually used.
>> 
>> What I was warning you about is that if you shrink the array to the
>> exact size, there might be other data that comes on the same cacheline,
>> which might cause all kinds of interesting behavior (I think they call
>> this false cache sharing or some such thing).

timur> Ok, I understand your explanation, but I have a hard time seeing how false
timur> cache sharing can be a bad thing.

timur> If the cache sucks up a bunch of zeros that are never used, that's definitely
timur> wasted cache space.  How can that be any better than sucking up some real data
timur> that can be used?



You put there a variable that is written a lot of times, then the
cache line with that array will be doing ping pong from one CPU to the
other.  Now, like it is a read only data, it can be in both caches at
the same time.  If you have a lot of CPUs problem become worst.

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
