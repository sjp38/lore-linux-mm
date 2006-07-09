Subject: RE: Commenting out out_of_memory() function in __alloc_pages()
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <BKEKJNIHLJDCFGDBOHGMCEEGDCAA.abum@aftek.com>
References: <BKEKJNIHLJDCFGDBOHGMCEEGDCAA.abum@aftek.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Sun, 09 Jul 2006 12:55:07 +0100
Message-Id: <1152446107.27368.45.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Abu M. Muttalib" <abum@aftek.com>
Cc: Robert Hancock <hancockr@shaw.ca>, chase.venters@clientec.com, kernelnewbies@nl.linux.org, linux-newbie@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ar Sul, 2006-07-09 am 09:53 +0530, ysgrifennodd Abu M. Muttalib:
> Hi,
> 
> I tried with the /proc/sys/vm/overcommit_memory=2 and the system refused to
> load the program altogether.
> 
> In this scenario is making overcommit_memory=2 a good idea?

It will refuse to load the program if that would use enough memory that
the system cannot be sure it will not run out of memory having done so.
You probably need a lot more swap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
