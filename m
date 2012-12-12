Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 5966E6B007D
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 05:48:09 -0500 (EST)
Message-ID: <50C860AD.5040504@huawei.com>
Date: Wed, 12 Dec 2012 18:47:09 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH V4 3/3] MCE: fix an error of mce_bad_pages statistics
References: <50C7FB85.8040008@huawei.com> <20121212102523.GA8760@liondog.tnic>
In-Reply-To: <20121212102523.GA8760@liondog.tnic>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, WuJianguo <wujianguo@huawei.com>, Liujiang <jiang.liu@huawei.com>, Simon Jeons <simon.jeons@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2012/12/12 18:25, Borislav Petkov wrote:

> On Wed, Dec 12, 2012 at 11:35:33AM +0800, Xishi Qiu wrote:
>> Since MCE is an x86 concept, and this code is in mm/, it would be
>> better to use the name num_poisoned_pages instead of mce_bad_pages.
>>
>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
>> Signed-off-by: Borislav Petkov <bp@alien8.de>
> 
> This is not how Signed-of-by: works. You should read
> Documentation/SubmittingPatches (yes, the whole of it) about how that
> whole S-o-b thing works.
> 
> And, FWIW, it should be "Suggested-by: Borislav Petkov <bp@alien8.de>"
> 
> Thanks.
> 

Sorry, I will pay more attention to it next time, thank you. :>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
