Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B17975F0001
	for <linux-mm@kvack.org>; Sun, 19 Apr 2009 08:38:56 -0400 (EDT)
Date: Sun, 19 Apr 2009 21:39:13 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: + mtd-mtd-in-mtd_release-is-unused-without-config_mtd_char.patch added to -mm tree
In-Reply-To: <1240070195.29546.3.camel@iris.sw.ru>
References: <20090418152635.125D.A69D9226@jp.fujitsu.com> <1240070195.29546.3.camel@iris.sw.ru>
Message-Id: <20090419213812.FFC5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Denis V. Lunev" <den@openvz.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, dwmw2@infradead.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> already fixed by Andrew by 
>   mtd-mtd-in-mtd_release-is-unused-without-config_mtd_char-fix

Oh, thanks.

 - kosaki

> 
> > ------------------------------------------------------
> > Subject: mtd-mtd-in-mtd_release-is-unused-without-config_mtd_char-fix
> > From: Andrew Morton <akpm@linux-foundation.org>
> > 
> > Cc: David Woodhouse <dwmw2@infradead.org>
> > Cc: Denis V. Lunev <den@openvz.org>
> > Cc: Randy Dunlap <randy.dunlap@oracle.com>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> > 
> >  drivers/mtd/mtdcore.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff -puN
> drivers/mtd/mtdcore.c~mtd-mtd-in-mtd_release-is-unused-without-config_mtd_char-fix drivers/mtd/mtdcore.c
> > ---
> a/drivers/mtd/mtdcore.c~mtd-mtd-in-mtd_release-is-unused-without-config_mtd_char-fix
> > +++ a/drivers/mtd/mtdcore.c
> > @@ -48,7 +48,7 @@ static LIST_HEAD(mtd_notifiers);
> >   */
> >  static void mtd_release(struct device *dev)
> >  {
> > -     dev_t index = MTD_DEVT(dev_to_mtd(dev));
> > +     dev_t index = MTD_DEVT(dev_to_mtd(dev)->index);
> >  
> >       /* remove /dev/mtdXro node if needed */
> >       if (index)
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
