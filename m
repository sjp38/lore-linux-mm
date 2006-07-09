From: "Abu M. Muttalib" <abum@aftek.com>
Subject: RE: Commenting out out_of_memory() function in __alloc_pages()
Date: Sun, 9 Jul 2006 20:04:52 +0530
Message-ID: <BKEKJNIHLJDCFGDBOHGMIEFJDCAA.abum@aftek.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-reply-to: <44B0F0AA.20708@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Robert Hancock <hancockr@shaw.ca>, chase.venters@clientec.com, kernelnewbies@nl.linux.org, linux-newbie@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>Abu, I guess you have turned on CONFIG_EMBEDDED and disabled everything
>you don't need, turned off full sized data structures, removed everything
>else you don't need from the kernel config, turned off kernel debugging
>(especially slab debugging).

Do you mean that I have configured kernel with CONFIG_EMBEDDED option??

>If you still have problems, what does /proc/slabinfo tell you when running
>your application under both 2.4 and 2.6?

Will find out the differences..

Regards,
Abu.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
