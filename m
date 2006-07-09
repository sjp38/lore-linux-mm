Subject: RE: Commenting out out_of_memory() function in __alloc_pages()
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <BKEKJNIHLJDCFGDBOHGMAEFDDCAA.abum@aftek.com>
References: <BKEKJNIHLJDCFGDBOHGMAEFDDCAA.abum@aftek.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Sun, 09 Jul 2006 13:09:57 +0100
Message-Id: <1152446997.27368.52.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Abu M. Muttalib" <abum@aftek.com>
Cc: Robert Hancock <hancockr@shaw.ca>, chase.venters@clientec.com, kernelnewbies@nl.linux.org, linux-newbie@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ar Sul, 2006-07-09 am 17:18 +0530, ysgrifennodd Abu M. Muttalib:
> but I am running the application on an embedded device and have no swap..
> what do I need to do in this case??

Use less memory ?

You can play with /proc/sys/vm/overcommit_ratio. That is set at 50%
which is usually a good safe value with swap. If you know the kernel and
kernel memory will be 20% of memory worst case you can set it to 80 and
so on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
