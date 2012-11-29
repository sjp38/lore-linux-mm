Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 9C83F6B005A
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 05:52:12 -0500 (EST)
Received: by mail-la0-f41.google.com with SMTP id m15so11541756lah.14
        for <linux-mm@kvack.org>; Thu, 29 Nov 2012 02:52:10 -0800 (PST)
Message-ID: <50B73E56.4050603@googlemail.com>
Date: Thu, 29 Nov 2012 10:52:06 +0000
From: Chris Clayton <chris2553@googlemail.com>
MIME-Version: 1.0
Subject: Re: [RFT PATCH v2 4/5] mm: provide more accurate estimation of pages
 occupied by memmap
References: <20121120111942.c9596d3f.akpm@linux-foundation.org> <1353510586-6393-1-git-send-email-jiang.liu@huawei.com> <20121128155221.df369ce4.akpm@linux-foundation.org>
In-Reply-To: <20121128155221.df369ce4.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <liuj97@gmail.com>, Wen Congyang <wency@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/28/12 23:52, Andrew Morton wrote:
> On Wed, 21 Nov 2012 23:09:46 +0800
> Jiang Liu <liuj97@gmail.com> wrote:
>
>> Subject: Re: [RFT PATCH v2 4/5] mm: provide more accurate estimation of pages occupied by memmap
>
> How are people to test this?  "does it boot"?
>

I've been running kernels with Gerry's 5 patches applied for 11 days 
now. This is on a 64bit laptop but with a 32bit kernel + HIGHMEM. I 
joined the conversation because my laptop would not resume from suspend 
to disk - it either froze or rebooted. With the patches applied the 
laptop does successfully resume and has been stable.

Since Monday, I have have been running a kernel with the patches (plus, 
from today, the patch you mailed yesterday) applied to 3.7rc7, without 
problems.

Thanks,
Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
