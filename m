Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 607876B0071
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 08:45:11 -0500 (EST)
Date: Tue, 11 Dec 2012 14:45:09 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH V3 1/2] MCE: fix an error of mce_bad_pages statistics
Message-ID: <20121211134509.GB16230@one.firstfloor.org>
References: <50C72493.3080009@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50C72493.3080009@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: WuJianguo <wujianguo@huawei.com>, Liujiang <jiang.liu@huawei.com>, Simon Jeons <simon.jeons@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@alien8.de>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Dec 11, 2012 at 08:18:27PM +0800, Xishi Qiu wrote:
> 1) move poisoned page check at the beginning of the function.
> 2) add page_lock to avoid unpoison clear the flag.

That doesn't make sense, obviously you would need to recheck
inside the lock again to really protect against unpoison.

But unpoison is only for debugging anyways, so it doesn't matter
if the count is 100% correct.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
