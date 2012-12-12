Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 385A36B002B
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 23:23:19 -0500 (EST)
Date: Wed, 12 Dec 2012 05:23:16 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH V4 2/3] MCE: fix an error of mce_bad_pages statistics
Message-ID: <20121212042316.GC16230@one.firstfloor.org>
References: <50C7FB82.7050802@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50C7FB82.7050802@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: WuJianguo <wujianguo@huawei.com>, Liujiang <jiang.liu@huawei.com>, Simon Jeons <simon.jeons@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@alien8.de>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

>  	if (PageHWPoison(hpage)) {
>  		pr_info("soft offline: %#lx hugepage already poisoned\n", pfn);
> -		return -EBUSY;
> +		ret = -EBUSY;
> +		goto out;


Doesn't look like a code improvement to me. Single return is easier and
simpler.

-Andi

> +out:
>  	return ret;
>  }
> -- 
> 1.7.1
> 
> 

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
