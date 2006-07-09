Date: Sun, 9 Jul 2006 14:15:11 +0200
From: Willy Tarreau <w@1wt.eu>
Subject: Re: Commenting out out_of_memory() function in __alloc_pages()
Message-ID: <20060709121511.GD2037@1wt.eu>
References: <20060709120138.GC2037@1wt.eu> <BKEKJNIHLJDCFGDBOHGMCEFFDCAA.abum@aftek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BKEKJNIHLJDCFGDBOHGMCEFFDCAA.abum@aftek.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Abu M. Muttalib" <abum@aftek.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Robert Hancock <hancockr@shaw.ca>, chase.venters@clientec.com, kernelnewbies@nl.linux.org, linux-newbie@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jul 09, 2006 at 05:43:11PM +0530, Abu M. Muttalib wrote:
> Thanks Willy for your reply..
> 
> In this context will you please help me understand/give some pointer to
> understand the various field in the output of /proc/meminfo!!

It's explained in Documentation/filesystems/proc.txt. This file know far
more things than me :-)

> Anticipation and regards,
> Abu.

Regards,
willy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
