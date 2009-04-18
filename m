Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 542965F0001
	for <linux-mm@kvack.org>; Sat, 18 Apr 2009 11:55:36 -0400 (EDT)
Subject: Re: +
 mtd-mtd-in-mtd_release-is-unused-without-config_mtd_char.patch added to -mm
 tree
From: "Denis V. Lunev" <den@openvz.org>
In-Reply-To: <20090418152635.125D.A69D9226@jp.fujitsu.com>
References: <200904150009.n3F095J1011993@imap1.linux-foundation.org>
	 <20090418152635.125D.A69D9226@jp.fujitsu.com>
Content-Type: text/plain
Date: Sat, 18 Apr 2009 19:56:35 +0400
Message-Id: <1240070195.29546.3.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, dwmw2@infradead.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

already fixed by Andrew by 
  mtd-mtd-in-mtd_release-is-unused-without-config_mtd_char-fix

> ------------------------------------------------------
> Subject: mtd-mtd-in-mtd_release-is-unused-without-config_mtd_char-fix
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> Cc: David Woodhouse <dwmw2@infradead.org>
> Cc: Denis V. Lunev <den@openvz.org>
> Cc: Randy Dunlap <randy.dunlap@oracle.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/mtd/mtdcore.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN
drivers/mtd/mtdcore.c~mtd-mtd-in-mtd_release-is-unused-without-config_mtd_char-fix drivers/mtd/mtdcore.c
> ---
a/drivers/mtd/mtdcore.c~mtd-mtd-in-mtd_release-is-unused-without-config_mtd_char-fix
> +++ a/drivers/mtd/mtdcore.c
> @@ -48,7 +48,7 @@ static LIST_HEAD(mtd_notifiers);
>   */
>  static void mtd_release(struct device *dev)
>  {
> -     dev_t index = MTD_DEVT(dev_to_mtd(dev));
> +     dev_t index = MTD_DEVT(dev_to_mtd(dev)->index);
>  
>       /* remove /dev/mtdXro node if needed */
>       if (index)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
