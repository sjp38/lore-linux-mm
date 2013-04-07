Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id C91CB6B0006
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 04:01:11 -0400 (EDT)
Date: Sun, 7 Apr 2013 10:00:18 +0200
From: Hans-Christian Egtvedt <egtvedt@samfundet.no>
Subject: Re: [PATCH v4, part3 02/41] avr32: normalize global variables
 exported by vmlinux.lds
Message-ID: <20130407080018.GB31879@samfundet.no>
References: <1365258760-30821-1-git-send-email-jiang.liu@huawei.com>
 <1365258760-30821-3-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365258760-30821-3-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Haavard Skinnemoen <hskinnemoen@gmail.com>

Around Sat 06 Apr 2013 22:32:01 +0800 or thereabout, Jiang Liu wrote:
> Normalize global variables exported by vmlinux.lds to conform usage
> guidelines from include/asm-generic/sections.h.
> 
> Use _text to mark the start of the kernel image including the head text,
> and _stext to mark the start of the .text section.

I'm assuming this series of patches makes this change.

> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>
> Cc: Hans-Christian Egtvedt <egtvedt@samfundet.no>
> Cc: linux-kernel@vger.kernel.org

Acked-by: Hans-Christian Egtvedt <egtvedt@samfundet.no>

> ---
>  arch/avr32/kernel/setup.c       |    2 +-
>  arch/avr32/kernel/vmlinux.lds.S |    4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)

<snipp diff>

-- 
mvh
Hans-Christian Egtvedt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
