Date: Mon, 22 Jul 2002 13:35:42 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: alloc_pages_bulk
Message-ID: <1624320000.1027370142@flay>
In-Reply-To: <3D3C6A88.D6798722@zip.com.au>
References: <1615040000.1027363248@flay> <3D3C6A88.D6798722@zip.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Bill Irwin <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>                 min += z->pages_min;
>>                 if (z->free_pages > min) {
>> -                       page = rmqueue(z, order);
>> +                       page = rmqueue(z, order, count, pages);
> 
> This won't compile because your rmqueue() no longer returns a
> page pointer.  

Arse. Will fix that in a second.

> d) Look at pages_min versus count before allocating any pages.  If
>    the allocation of `count' pagess would cause ->free_pages to fall
>    below min, then go run some reclaim _first_, and then go grab a
>    number of pages.  That number is min(count, nr_pages_we_just_reclaimed).
>    So the caller may see a partial result.
> 
> I think d), yes?

I was under the impression I was already doing that by this bit at the
start of the loop:

-       min = 1UL << order;
+       min = count << order;

Is that sufficient already (obviously my returns from rmqueue are total crap, 
but other than that ... ;-))

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
