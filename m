From: "Abu M. Muttalib" <abum@aftek.com>
Subject: RE: [RFC PATCH] prevent from killing OOM disabled task indo_page_fault()
Date: Thu, 24 Aug 2006 17:14:52 +0530
Message-ID: <BKEKJNIHLJDCFGDBOHGMCENPDGAA.abum@aftek.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
In-Reply-To: <1156419794.3007.99.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Akinobu Mita <mita@miraclelinux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

> > > The process protected from oom-killer may be killed when
do_page_fault()
> > > runs out of memory. This patch skips those processes as well as init
task.
> >
> > Do we have any patch set to disable OOM all together for linux kernel
> > 2.6.13?
>
> No, its run tme configurable as is selection priority of the processes
> which you want killed, has been for some time.

Will you please elaborate upon your reply.

Thanks,
Abu.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
