Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 8973A6B00A6
	for <linux-mm@kvack.org>; Wed, 29 May 2013 04:52:24 -0400 (EDT)
Message-ID: <51A5C1AE.6000805@synopsys.com>
Date: Wed, 29 May 2013 14:21:58 +0530
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8, part3 02/14] mm: enhance free_reserved_area() to support
 poisoning memory with zero
References: <1369575522-26405-1-git-send-email-jiang.liu@huawei.com> <1369575522-26405-3-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1369575522-26405-3-git-send-email-jiang.liu@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>

On 05/26/2013 07:08 PM, Jiang Liu wrote:
> Address more review comments from last round of code review.
> 1) Enhance free_reserved_area() to support poisoning freed memory with
>    pattern '0'. This could be used to get rid of poison_init_mem()
>    on ARM64.
> 2) A previous patch has disabled memory poison for initmem on s390
>    by mistake, so restore to the original behavior.
> 3) Remove redundant PAGE_ALIGN() when calling free_reserved_area().
> 
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>

Can you apply these to you github v5 branch as well !

Thx,
-Vineet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
