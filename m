Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id D96CE6B0075
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 20:25:11 -0500 (EST)
Message-ID: <50B6B936.10200@cn.fujitsu.com>
Date: Thu, 29 Nov 2012 09:24:06 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] Add movablecore_map boot option
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <CAA_GA1d7CxHvmZELvD_DO6u5tu1WBqfmLiuEzeFo=xMzuW50Tg@mail.gmail.com> <50B479FA.6010307@cn.fujitsu.com> <CAA_GA1ezZJyqVL=Dp5U2zzNw6bkfMKJY_STkt3E7TXkUYcv+jQ@mail.gmail.com> <50B4B6BE.3000902@cn.fujitsu.com> <CAA_GA1fE0fhLVs50rRZ6OsTw7DV0hyVC2EuRyUrbzxLztPLoeg@mail.gmail.com> <50B58E30.9060804@huawei.com> <50B5CB4D.6070402@cn.fujitsu.com> <20121129004323.GA9058@kernel>
In-Reply-To: <20121129004323.GA9058@kernel>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, Bob Liu <lliubbo@gmail.com>, hpa@zytor.com, akpm@linux-foundation.org, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, m.szyprowski@samsung.com

On 11/29/2012 08:43 AM, Jaegeuk Hanse wrote:
> Hi Tang,
>
> I haven't read the patchset yet, but could you give a short describe how
> you design your implementation in this patchset?
>
> Regards,
> Jaegeuk
>

Hi Jaegeuk,

Thanks for your joining in. :)

This feature is used in memory hotplug.

In order to implement a whole node hotplug, we need to make sure the
node contains no kernel memory, because memory used by kernel could
not be migrated. (Since the kernel memory is directly mapped,
VA = PA + __PAGE_OFFSET. So the physical address could not be changed.)

With this boot option, user could specify all the memory on a node to
be movable(which means they are in ZONE_MOVABLE), so that the node
could be hot-removed.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
