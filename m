Date: Wed, 06 Feb 2008 10:54:11 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] badness() dramatically overcounts memory
In-Reply-To: <alpine.DEB.1.00.0802051507460.18347@chino.kir.corp.google.com>
References: <1202252561.24634.64.camel@dogma.ljc.laika.com> <alpine.DEB.1.00.0802051507460.18347@chino.kir.corp.google.com>
Message-Id: <20080206105041.2717.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Jeff Davis <linux@j-davis.com>, balbir@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <andrea@qumranet.com>
List-ID: <linux-mm.kvack.org>

Hi

> > > The interesting thing is the use of total_vm and not the RSS which is used as
> > > the basis by the OOM killer. I need to read/understand the code a bit more.
> > 
> > RSS makes more sense to me as well.
> 
> Andrea Arcangeli has patches pending which change this to the RSS.  
> Specifically:
> 
> 	http://marc.info/?l=linux-mm&m=119977937126925

I agreed with you that RSS is better :)



but..
on many node numa, per zone rss is more better..


- kosaki


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
