Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5898D6B005A
	for <linux-mm@kvack.org>; Tue, 26 May 2009 03:00:12 -0400 (EDT)
Received: by an-out-0708.google.com with SMTP id d14so1795758and.26
        for <linux-mm@kvack.org>; Tue, 26 May 2009 00:00:11 -0700 (PDT)
Date: Tue, 26 May 2009 15:59:43 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH][mmtom] clean up once printk routine
Message-Id: <20090526155943.aef3ba62.minchan.kim@barrios-desktop>
In-Reply-To: <20090526155155.6871.A69D9226@jp.fujitsu.com>
References: <20090526135733.3c38f758.minchan.kim@barrios-desktop>
	<20090526155155.6871.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, Randy Dunlap <randy.dunlap@oracle.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, "David S. Miller" <davem@davemloft.net>, Dominik Brodowski <linux@dominikbrodowski.net>, Ingo Molnar <mingo@elte.hu>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 26 May 2009 15:52:32 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > == CUT HERE ==
> > 
> > There are some places to be able to use printk_once instead of hard coding.
> > 
> > It will help code readability and maintenance.
> > This patch doesn't change function's behavior.
> > 
> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> > CC: Dominik Brodowski <linux@dominikbrodowski.net>
> > CC: David S. Miller <davem@davemloft.net>
> > CC: Ingo Molnar <mingo@elte.hu>
> > ---
> >  arch/x86/kernel/cpu/common.c  |    8 ++------
> >  drivers/net/3c515.c           |    7 ++-----
> >  drivers/pcmcia/pcmcia_ioctl.c |    9 +++------
> >  3 files changed, 7 insertions(+), 17 deletions(-)
> 
> Please separete to three patches ;)

After I listen about things I missed, I will repost it at all once with each patch.
Thanks for comment. Kosaki. :)


-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
