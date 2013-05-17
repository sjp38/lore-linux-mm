Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id EF8956B0032
	for <linux-mm@kvack.org>; Fri, 17 May 2013 11:28:28 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id r11so126860pdi.21
        for <linux-mm@kvack.org>; Fri, 17 May 2013 08:28:28 -0700 (PDT)
Message-ID: <51964C95.2010401@gmail.com>
Date: Fri, 17 May 2013 23:28:21 +0800
From: Liu Jiang <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6, part3 16/16] AVR32: fix building warnings caused by
 redifinitions of HZ
References: <1368293689-16410-17-git-send-email-jiang.liu@huawei.com> <1368293689-16410-1-git-send-email-jiang.liu@huawei.com> <15932.1368438005@warthog.procyon.org.uk>
In-Reply-To: <15932.1368438005@warthog.procyon.org.uk>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Haavard Skinnemoen <hskinnemoen@gmail.com>

On 05/13/2013 05:40 PM, David Howells wrote:
> Jiang Liu <liuj97@gmail.com> wrote:
>
>> -#ifndef HZ
>> +#ifndef __KERNEL__
>> +   /*
>> +    * Technically, this is wrong, but some old apps still refer to it.
>> +    * The proper way to get the HZ value is via sysconf(_SC_CLK_TCK).
>> +    */
>>   # define HZ		100
>>   #endif
> Better still, use asm-generic/param.h and uapi/asm-generic/param.h for AVR32
> instead.
>
> David
>
Hi David,
         Great idea! Will use generic param.h for AVR32.
Regards!
Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
