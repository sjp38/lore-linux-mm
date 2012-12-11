Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 34C0E6B0069
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 22:26:19 -0500 (EST)
Message-ID: <50C6A7BC.8010200@huawei.com>
Date: Tue, 11 Dec 2012 11:25:48 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2] MCE: fix an error of mce_bad_pages statistics
References: <50C1AD6D.7010709@huawei.com> <20121207141102.4fda582d.akpm@linux-foundation.org> <20121210083342.GA31670@hacker.(null)> <50C5A62A.6030401@huawei.com> <1355136423.1700.2.camel@kernel.cn.ibm.com> <50C5C4A2.2070002@huawei.com> <20121210153805.GS16230@one.firstfloor.org> <50C6997C.1080702@huawei.com> <20121211024522.GA10505@localhost> <20121211025857.GX16230@one.firstfloor.org>
In-Reply-To: <20121211025857.GX16230@one.firstfloor.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Simon Jeons <simon.jeons@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, WuJianguo <wujianguo@huawei.com>, Liujiang <jiang.liu@huawei.com>, Vyacheslav.Dubeyko@huawei.com, Borislav Petkov <bp@alien8.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wency@cn.fujitsu.com, Hanjun Guo <guohanjun@huawei.com>

On 2012/12/11 10:58, Andi Kleen wrote:

>> That sounds like overkill. There are not so many free pages in a
>> typical server system.
> 
> As Fengguang said -- memory error handling is tricky. Lots of things
> could be done in theory, but they all have a cost in testing and 
> maintenance. 
> 
> In general they are only worth doing if the situation is common and
> represents a significant percentage of the total pages of a relevant server
> workload.
> 
> -Andi
> 

Hi Andi and Fengguang,

"There are not so many free pages in a typical server system", sorry I don't
quite understand it.

buffered_rmqueue()
	prep_new_page()
		check_new_page()
			bad_page()

If we alloc 2^10 pages and one of them is a poisoned page, then the whole 4M
memory will be dropped.

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
