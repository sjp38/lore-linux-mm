Subject: RE: [RFC PATCH] prevent from killing OOM disabled task in
	do_page_fault()
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <BKEKJNIHLJDCFGDBOHGMMENIDGAA.abum@aftek.com>
References: <BKEKJNIHLJDCFGDBOHGMMENIDGAA.abum@aftek.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Thu, 24 Aug 2006 12:43:14 +0100
Message-Id: <1156419794.3007.99.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Abu M. Muttalib" <abum@aftek.com>
Cc: Akinobu Mita <mita@miraclelinux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ar Iau, 2006-08-24 am 15:43 +0530, ysgrifennodd Abu M. Muttalib:
> Hi,
> 
> > The process protected from oom-killer may be killed when do_page_fault()
> > runs out of memory. This patch skips those processes as well as init task.
> 
> Do we have any patch set to disable OOM all together for linux kernel
> 2.6.13?

No, its run tme configurable as is selection priority of the processes
which you want killed, has been for some time.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
