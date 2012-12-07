Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 6874D6B005D
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 02:46:45 -0500 (EST)
Date: Fri, 7 Dec 2012 08:46:43 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH] MCE: fix an error of mce_bad_pages statistics
Message-ID: <20121207074643.GA27523@liondog.tnic>
References: <50C15A35.5020007@huawei.com>
 <20121207072541.GA27708@liondog.tnic>
 <50C19C33.9030502@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <50C19C33.9030502@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: WuJianguo <wujianguo@huawei.com>, Liujiang <jiang.liu@huawei.com>, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Fri, Dec 07, 2012 at 03:35:15PM +0800, Xishi Qiu wrote:
> Hi Borislav, you mean we should move this to the beginning of soft_offline_page()?
> 
> soft_offline_page()
> {
> 	...
> 	get_any_page()
> 	...
> 	/*
> 	 * Synchronized using the page lock with memory_failure()
> 	 */
> 	if (PageHWPoison(page)) {
> 		unlock_page(page);

Basically yes, except without the unlock_page. Where do you do lock_page
earlier so that you need to unlock it now?

Thanks.

-- 
Regards/Gruss,
    Boris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
