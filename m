Date: Wed, 2 Feb 2000 14:41:02 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: 2.3.42: Strange memory corruption
In-Reply-To: <20000202051433.A298@tony.dorf.wh.uni-dortmund.de>
Message-ID: <Pine.LNX.4.10.10002021439170.462-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Patrick Mau <patrick@oscar.prima.de>
Cc: Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2 Feb 2000, Patrick Mau wrote:

> I have a really strange memory corruption problem with
> 2.3.42. My system configuration is as follows:

> After a few md5sums I get different checksums.
> Now I check the file with bzip2 and get a CRC error.
> 
> Now I make a copy (plain 'cp') of that file.
> 
> Then I repeat the above with the copy and get different
> checksums and also CRC errors from bzip2. (I expected that).
> 
> --> Here comes the strange part <---
> 
> Now I reboot into 2.3.30. Same config.
> And BOTH files, even the 'corrupt' copy, are
> correct.  I can run the md5sum test AND can uncompress
> BOTH of them. I can always reproduce that.

This looks a bit like there might be a race with the
pagetable mapping or read()ing of the file. It would
explain the three `suspicious' segfaults I've seen in
the last few days...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
