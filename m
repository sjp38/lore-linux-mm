Subject: RE: [RFC PATCH] prevent from killing OOM disabled task
	indo_page_fault()
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <BKEKJNIHLJDCFGDBOHGMCENPDGAA.abum@aftek.com>
References: <BKEKJNIHLJDCFGDBOHGMCENPDGAA.abum@aftek.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Thu, 24 Aug 2006 13:32:47 +0100
Message-Id: <1156422767.3007.111.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Abu M. Muttalib" <abum@aftek.com>
Cc: Akinobu Mita <mita@miraclelinux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ar Iau, 2006-08-24 am 17:14 +0530, ysgrifennodd Abu M. Muttalib:
> > No, its run tme configurable as is selection priority of the processes
> > which you want killed, has been for some time.
> 
> Will you please elaborate upon your reply.

See
	Documentation/sysctl/vm.txt
	Documenation/filesystems/proc.txt  (look for oom_adj)

in 2.6.18-rc

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
