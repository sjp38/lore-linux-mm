Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 637276B0072
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 22:50:17 -0500 (EST)
Message-ID: <50B58965.7040703@cn.fujitsu.com>
Date: Wed, 28 Nov 2012 11:47:49 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] Add movablecore_map boot option
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <50B42F32.4050107@gmail.com>
In-Reply-To: <50B42F32.4050107@gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wujianguo <wujianguo106@gmail.com>
Cc: hpa@zytor.com, akpm@linux-foundation.org, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, jiang.liu@huawei.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On 11/27/2012 11:10 AM, wujianguo wrote:
>
> Hi Tang,
> 	DMA address can't be set as movable, if some one boot kernel with
> movablecore_map=4G@0xa00000 or other memory region that contains DMA address,
> system maybe boot failed. Should this case be handled or mentioned
> in the change log and kernel-parameters.txt?

Hi Wu,

I think we can use MAX_DMA_PFN and MAX_DMA32_PFN to prevent setting DMA
address as movable. Just ignore the address lower than them, and set
the rest as movable. How do you think ?

And, since we cannot figure out the minimum of memory kernel needs, I
think for now, we can just add some warning into kernel-parameters.txt.

Thanks. :)

>
> Thanks,
> Jianguo Wu
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
