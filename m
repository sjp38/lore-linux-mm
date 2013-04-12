Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 5ABFE6B0002
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 16:54:57 -0400 (EDT)
Message-ID: <5168749E.80008@tilera.com>
Date: Fri, 12 Apr 2013 16:54:54 -0400
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4, part3 06/41] tile: normalize global variables exported
 by vmlinux.lds
References: <1365258760-30821-1-git-send-email-jiang.liu@huawei.com> <1365258760-30821-7-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1365258760-30821-7-git-send-email-jiang.liu@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, Bjorn Helgaas <bhelgaas@google.com>, "David S. Miller" <davem@davemloft.net>

On 4/6/2013 10:32 AM, Jiang Liu wrote:
> Normalize global variables exported by vmlinux.lds to conform usage
> guidelines from include/asm-generic/sections.h.
>
> 1) Use _text to mark the start of the kernel image including the head
> text, and _stext to mark the start of the .text section.
> 2) Export mandatory global variables __init_begin and __init_end.
>
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> Cc: Chris Metcalf <cmetcalf@tilera.com>
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Bjorn Helgaas <bhelgaas@google.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Wen Congyang <wency@cn.fujitsu.com>
> Cc: David Howells <dhowells@redhat.com>
> Cc: linux-kernel@vger.kernel.org
> ---
>  arch/tile/include/asm/sections.h |    2 +-
>  arch/tile/kernel/setup.c         |    4 ++--
>  arch/tile/kernel/vmlinux.lds.S   |    4 +++-
>  arch/tile/mm/init.c              |    2 +-
>  4 files changed, 7 insertions(+), 5 deletions(-)

Acked-by: Chris Metcalf <cmetcalf@tilera.com>

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
