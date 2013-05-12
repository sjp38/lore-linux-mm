Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 1929D6B0034
	for <linux-mm@kvack.org>; Sun, 12 May 2013 11:13:50 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id jh10so4038534pab.17
        for <linux-mm@kvack.org>; Sun, 12 May 2013 08:13:49 -0700 (PDT)
Message-ID: <518FB1A5.8050303@gmail.com>
Date: Sun, 12 May 2013 23:13:41 +0800
From: Liu Jiang <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6, part3 15/16] mm: report available pages as "MemTotal"
 for each NUMA node
References: <1368293689-16410-1-git-send-email-jiang.liu@huawei.com> <1368293689-16410-16-git-send-email-jiang.liu@huawei.com> <518EA49F.50206@cogentembedded.com>
In-Reply-To: <518EA49F.50206@cogentembedded.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <james.bottomley@hansenpartnership.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun 12 May 2013 04:05:51 AM CST, Sergei Shtylyov wrote:
> Hello.
>
> On 05/11/2013 09:34 PM, Jiang Liu wrote:
>
>    I've noticed a small typo in the changelog.
>
>> As reported by https://bugzilla.kernel.org/show_bug.cgi?id=53501,
>> "MemTotal" from /proc/meminfo means memory pages managed by the buddy
>> system (managed_pages), but "MemTotal" from /sys/.../node/nodex/meminfo
>> means phsical pages present (present_pages) within the NUMA node.
>
>     s/phsical/physical/
Thanks Sergei, will fix it in next version.
Gerry

>
>> There's a difference between managed_pages and present_pages due to
>> bootmem allocator and reserved pages.
>>
>> And Documentation/filesystems/proc.txt says
>>      MemTotal: Total usable ram (i.e. physical ram minus a few reserved
>>                bits and the kernel binary code)
>>
>> So change /sys/.../node/nodex/meminfo to report available pages within
>> the node as "MemTotal".
>>
>> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
>> Reported-by: sworddragon2@aol.com
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: linux-mm@kvack.org
>> Cc: linux-kernel@vger.kernel.org
>
> WBR, Sergei
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
