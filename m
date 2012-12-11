Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 7A99B6B0062
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 21:25:39 -0500 (EST)
Message-ID: <50C6997C.1080702@huawei.com>
Date: Tue, 11 Dec 2012 10:25:00 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2] MCE: fix an error of mce_bad_pages statistics
References: <50C1AD6D.7010709@huawei.com> <20121207141102.4fda582d.akpm@linux-foundation.org> <20121210083342.GA31670@hacker.(null)> <50C5A62A.6030401@huawei.com> <1355136423.1700.2.camel@kernel.cn.ibm.com> <50C5C4A2.2070002@huawei.com> <20121210153805.GS16230@one.firstfloor.org>
In-Reply-To: <20121210153805.GS16230@one.firstfloor.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Simon Jeons <simon.jeons@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, WuJianguo <wujianguo@huawei.com>, Liujiang <jiang.liu@huawei.com>, Vyacheslav.Dubeyko@huawei.com, Borislav Petkov <bp@alien8.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wency@cn.fujitsu.com, fengguang.wu@intel.com, Hanjun Guo <guohanjun@huawei.com>

On 2012/12/10 23:38, Andi Kleen wrote:

>> It is another topic, I mean since the page is poisoned, so why not isolate it
>> from page buddy alocator in soft_offline_page() rather than in check_new_page().
>> I find soft_offline_page() only migrate the page and mark HWPoison, the poisoned
>> page is still managed by page buddy alocator.
> 
> Doing it in check_new_page is the only way if the page is currently
> allocated by someone. Since that's not uncommon it's simplest to always
> do it this way.
> 
> -Andi
> 

Hi Andi,

The poisoned page is isolated in check_new_page, however the whole buddy block will
be dropped, it seems to be a waste of memory.

Can we separate the poisoned page from the buddy block, then *only* drop the poisoned
page?

Thanks
Xishi Qiu


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
