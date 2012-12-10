Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 7ED756B005A
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 07:11:18 -0500 (EST)
Date: Mon, 10 Dec 2012 13:11:15 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH V2] MCE: fix an error of mce_bad_pages statistics
Message-ID: <20121210121114.GA13631@liondog.tnic>
References: <50C1AD6D.7010709@huawei.com>
 <20121207141102.4fda582d.akpm@linux-foundation.org>
 <20121210083342.GA31670@hacker.(null)>
 <50C5A62A.6030401@huawei.com>
 <1355136423.1700.2.camel@kernel.cn.ibm.com>
 <50C5C4A2.2070002@huawei.com>
 <20121210113923.GA5579@hacker.(null)>
 <50C5CD8D.8060505@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <50C5CD8D.8060505@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, WuJianguo <wujianguo@huawei.com>, Liujiang <jiang.liu@huawei.com>, Vyacheslav.Dubeyko@huawei.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wency@cn.fujitsu.com

On Mon, Dec 10, 2012 at 07:54:53PM +0800, Xishi Qiu wrote:
> One more question, can we add a list_head to manager the poisoned pages?

What would you need that list for? Also, a list is not the most optimal
data structure for when you need to traverse it often.

Thanks.

-- 
Regards/Gruss,
    Boris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
