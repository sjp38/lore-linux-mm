From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14202.16095.714040.234720@dukat.scot.redhat.com>
Date: Wed, 30 Jun 1999 16:59:27 +0100 (BST)
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
In-Reply-To: <Pine.LNX.4.10.9906291420110.13586-100000@laser.random>
References: <14200.46476.994769.970340@dukat.scot.redhat.com>
	<Pine.LNX.4.10.9906291420110.13586-100000@laser.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Chuck Lever <cel@monkey.org>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 29 Jun 1999 14:32:41 +0200 (CEST), Andrea Arcangeli
<andrea@suse.de> said:

> On Tue, 29 Jun 1999, Stephen C. Tweedie wrote:
>> Absolutely.  The important thing is to do enough swapping to make sure
>> that unused data is not kicking around in memory.  Maybe you don't want

> I know that sometime is the right thing do to.

> But think also a difference scenario. You have a machine that only reads
> all the time from a disk 10giga of data in loop. 

Absolutely.  The find|grep workload, for example.  The point is that
this memory load is different from the load imposed by a kernel build.
If you are using file IO more, you need to be turning the cache over
more.  

The old buffer cache had this property, and it worked very well indeed.
The buffer cache would try to recycle itself in preference to growing,
so for file-intensive workloads we would naturally evict cached data in
preference to swapping, but for memory-intensive compute workloads we
would be more likely to swap unused VM pages out.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
