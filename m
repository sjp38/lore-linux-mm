Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9CEC36B005C
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 12:56:39 -0400 (EDT)
Message-ID: <4A898BC4.70704@hp.com>
Date: Mon, 17 Aug 2009 12:56:36 -0400
From: jim owens <jowens@hp.com>
MIME-Version: 1.0
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
 slot is freed)
References: <3e8340490908131354q167840fcv124ec56c92bbb830@mail.gmail.com> <4A85E0DC.9040101@rtr.ca> <f3177b9e0908141621j15ea96c0s26124d03fc2b0acf@mail.gmail.com> <20090814234539.GE27148@parisc-linux.org> <f3177b9e0908141719s658dc79eye92ab46558a97260@mail.gmail.com> <1250341176.4159.2.camel@mulgrave.site> <4A86B69C.7090001@rtr.ca> <1250344518.4159.4.camel@mulgrave.site> <20090816150530.2bae6d1f@lxorguk.ukuu.org.uk> <20090816083434.2ce69859@infradead.org> <20090816154430.GE17958@mit.edu> <4A8841D7.10506@rtr.ca> <4A8843C3.3020409@rtr.ca> <4A8985B6.30103@tmr.com>
In-Reply-To: <4A8985B6.30103@tmr.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bill Davidsen <davidsen@tmr.com>
Cc: Mark Lord <liml@rtr.ca>, Theodore Tso <tytso@mit.edu>, Arjan van de Ven <arjan@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, James Bottomley <James.Bottomley@suse.de>, Chris Worley <worleys@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Bryan Donlan <bdonlan@gmail.com>, david@lang.hm, Greg Freemyer <greg.freemyer@gmail.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Bill Davidsen wrote:
> 
> I assume that it really is artificial, rather than the device really 
> being ready for another operation (other than another TRIM). I lack the 
> hardware, but the test would be the time to complete a read, trim and 
> read, and two trim and read operations. Just my thought that the TRIM in 
> progress may only block the next TRIM, rather than other operations.

I don't know his test sequence but READ is not the likely command
before and after TRIM unless we are talking about TRIM being issued
only in delayed host garbage collection.  Filesystems send WRITES
during delete.

jim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
