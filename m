Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 2C58A6B005A
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 22:13:16 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so2603850pad.14
        for <linux-mm@kvack.org>; Mon, 10 Dec 2012 19:13:15 -0800 (PST)
Message-ID: <1355195591.1933.18.camel@kernel.cn.ibm.com>
Subject: Re: [PATCH V2] MCE: fix an error of mce_bad_pages statistics
From: Simon Jeons <simon.jeons@gmail.com>
Date: Mon, 10 Dec 2012 21:13:11 -0600
In-Reply-To: <20121211030125.GY16230@one.firstfloor.org>
References: <50C1AD6D.7010709@huawei.com>
	 <20121207141102.4fda582d.akpm@linux-foundation.org>
	 <20121210083342.GA31670@hacker.(null)> <50C5A62A.6030401@huawei.com>
	 <1355136423.1700.2.camel@kernel.cn.ibm.com> <50C5C4A2.2070002@huawei.com>
	 <20121210153805.GS16230@one.firstfloor.org>
	 <1355190540.1933.4.camel@kernel.cn.ibm.com>
	 <20121211020313.GV16230@one.firstfloor.org>
	 <1355192071.1933.7.camel@kernel.cn.ibm.com>
	 <20121211030125.GY16230@one.firstfloor.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, WuJianguo <wujianguo@huawei.com>, Liujiang <jiang.liu@huawei.com>, Vyacheslav.Dubeyko@huawei.com, Borislav Petkov <bp@alien8.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wency@cn.fujitsu.com

On Tue, 2012-12-11 at 04:01 +0100, Andi Kleen wrote:
> > Oh, it will be putback to lru list during migration. So does your "some
> > time" mean before call check_new_page?
> 
> Yes until the next check_new_page() whenever that is. If the migration
> works it will be earlier, otherwise later.

But I can't figure out any page reclaim path check if the page is set
PG_hwpoison, can poisoned pages be rclaimed?

			-Simon

> 
> -andi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
