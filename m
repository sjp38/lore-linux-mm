Received: from saturn.homenet([192.168.225.55]) (1170 bytes) by megami.veritas.com
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <tigran@veritas.com>)
	id <m13PKft-0000NYC@megami.veritas.com>
	for <linux-mm@kvack.org>; Thu, 17 Aug 2000 01:05:17 -0700 (PDT)
	(Smail-3.2.0.101 1997-Dec-17 #4 built 1999-Aug-24)
Date: Thu, 17 Aug 2000 09:12:14 +0100 (BST)
From: Tigran Aivazian <tigran@veritas.com>
Subject: Re: 2.4.0-test7-pre4 oops in generic_make_request()
In-Reply-To: <14747.7309.941683.168466@notabene.cse.unsw.edu.au>
Message-ID: <Pine.LNX.4.21.0008170837360.1056-100000@saturn.homenet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Brown <neilb@cse.unsw.edu.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 17 Aug 2000, Neil Brown wrote:
> 
> But it looks like you are doing IO on a raw (drivers/char/raw.c)
> device, rather than /dev/hdd1.  Is that right?
> 

yes, you are right - I didn't know that myself ;) Of course I should have
guessed - our mkfs on other UNIX flavours does access the character (raw)
interface rather than buffered (block) one so the port to Linux had to do
the RAW_SETBIND magic and do the same...

Thanks for the patch - it works beautifully, added to my linux-vxfs chunk
but I hope Linus takes it into pre5.

Regards,
Tigran




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
