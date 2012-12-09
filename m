Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 9B2BC6B005D
	for <linux-mm@kvack.org>; Sun,  9 Dec 2012 03:11:43 -0500 (EST)
Message-ID: <50C44786.30509@cn.fujitsu.com>
Date: Sun, 09 Dec 2012 16:10:46 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 4/5] page_alloc: Make movablecore_map has higher priority
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <1353667445-7593-5-git-send-email-tangchen@cn.fujitsu.com> <50BF6BA0.8060505@gmail.com> <50BFF443.3090504@cn.fujitsu.com> <50C00259.50901@huawei.com>
In-Reply-To: <50C00259.50901@huawei.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: Jiang Liu <liuj97@gmail.com>, hpa@zytor.com, akpm@linux-foundation.org, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

Hi Liu, Wu,

On 12/06/2012 10:26 AM, Jiang Liu wrote:
> On 2012-12-6 9:26, Tang Chen wrote:
>> On 12/05/2012 11:43 PM, Jiang Liu wrote:
>>> If we make "movablecore_map" take precedence over "movablecore/kernelcore",
>>> the logic could be simplified. I think it's not so attractive to support
>>> both "movablecore_map" and "movablecore/kernelcore" at the same time.

Thanks for the advice of removing movablecore/kernelcore. But since we
didn't plan to do this in the beginning, and movablecore/kernelcore are
more user friendly, I think for now, I'll handle DMA and low memory 
address problems as you mentioned, and just keep movablecore/kernelcore
in the next version. :)

And about the SRAT, I think it is necessary to many users. I think we
should provide both interfaces. I may give a try in the next version.

Thanks. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
