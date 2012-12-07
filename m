Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 58A636B0095
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 17:41:13 -0500 (EST)
Date: Fri, 7 Dec 2012 23:41:10 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH V2] MCE: fix an error of mce_bad_pages statistics
Message-ID: <20121207224110.GA32115@liondog.tnic>
References: <50C1AD6D.7010709@huawei.com>
 <20121207141102.4fda582d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20121207141102.4fda582d.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, WuJianguo <wujianguo@huawei.com>, Liujiang <jiang.liu@huawei.com>, Vyacheslav.Dubeyko@huawei.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 07, 2012 at 02:11:02PM -0800, Andrew Morton wrote:
> A few things:
> 
> - soft_offline_page() already checks for this case:
> 
> 	if (PageHWPoison(page)) {
> 		unlock_page(page);
> 		put_page(page);
> 		pr_info("soft offline: %#lx page already poisoned\n", pfn);
> 		return -EBUSY;
> 	}

Oh, so we do this check after all. But later in the function. Why? Why
not at the beginning so that when a page is marked poisoned already we
can exit early?

Strange.

-- 
Regards/Gruss,
    Boris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
