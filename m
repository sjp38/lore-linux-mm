Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA24991
	for <linux-mm@kvack.org>; Wed, 27 Jan 1999 07:13:57 -0500
Date: Wed, 27 Jan 1999 12:13:27 GMT
Message-Id: <199901271213.MAA04281@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.96.990126025518.3579A-100000@laser.bogus>
References: <199901251625.QAA04452@dax.scot.redhat.com>
	<Pine.LNX.3.96.990126025518.3579A-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, werner@suse.de, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 26 Jan 1999 02:57:41 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

>> /* We can't free pages unless there's just one user */
>> if (atomic_read(&page->count) != 1)
>> continue;
>> +
>> +		count--;

> but this is plain bogus. When your machine will reach 0 freeable pages
> (and that happens a bit before to kill the process because OOM) you'll get
> an infinite loop in shrink_mmap().

No.  We skip only shared pages.  We still count page tables, vmalloced
pages, task structs, kmalloc/slab pages, dma buffers and all those other
kernel pages which do not belong to the VM.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
