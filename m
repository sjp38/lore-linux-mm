Date: Mon, 03 Mar 2008 18:49:16 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2.6.24] mm: BadRAM support for broken memory
In-Reply-To: <200803031835.03082.nickpiggin@yahoo.com.au>
References: <20080303161025.1E7E.KOSAKI.MOTOHIRO@jp.fujitsu.com> <200803031835.03082.nickpiggin@yahoo.com.au>
Message-Id: <20080303184453.1E8C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: kosaki.motohiro@jp.fujitsu.com, KOSAKI Motohiro <m-kosaki@ceres.dti.ne.jp>, Rick van Rein <rick@vanrein.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > as far as I know, IA64 already use PG_reserved for bad memory.
> > please see arch/ia64/kernel/mcs_drv.c#mca_page_isolate.
> >
> > Doesn't it works on ia64 if your patch introduce?
> 
> It doesn't really need to use PG_reserved there, no. It could
> use PG_bad for that instead.

unfortunately that feature already merged to mainline.
and i am not its developer, sorry ;)

- kosaki


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
