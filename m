Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 46F5F6B0073
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 05:25:27 -0500 (EST)
Date: Wed, 12 Dec 2012 11:25:24 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH V4 3/3] MCE: fix an error of mce_bad_pages statistics
Message-ID: <20121212102523.GA8760@liondog.tnic>
References: <50C7FB85.8040008@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <50C7FB85.8040008@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: WuJianguo <wujianguo@huawei.com>, Liujiang <jiang.liu@huawei.com>, Simon Jeons <simon.jeons@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 12, 2012 at 11:35:33AM +0800, Xishi Qiu wrote:
> Since MCE is an x86 concept, and this code is in mm/, it would be
> better to use the name num_poisoned_pages instead of mce_bad_pages.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> Signed-off-by: Borislav Petkov <bp@alien8.de>

This is not how Signed-of-by: works. You should read
Documentation/SubmittingPatches (yes, the whole of it) about how that
whole S-o-b thing works.

And, FWIW, it should be "Suggested-by: Borislav Petkov <bp@alien8.de>"

Thanks.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
