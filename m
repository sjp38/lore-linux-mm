Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 6A21B6B0036
	for <linux-mm@kvack.org>; Mon, 13 May 2013 05:42:51 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <15961.1368438077@warthog.procyon.org.uk>
References: <15961.1368438077@warthog.procyon.org.uk> <1368293689-16410-3-git-send-email-jiang.liu@huawei.com> <1368293689-16410-1-git-send-email-jiang.liu@huawei.com>
Subject: Re: [PATCH v6, part3 02/16] mm: enhance free_reserved_area() to support poisoning memory with zero
Date: Mon, 13 May 2013 10:42:37 +0100
Message-ID: <15994.1368438157@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: dhowells@redhat.com, Jiang Liu <liuj97@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>

David Howells <dhowells@redhat.com> wrote:

> Jiang Liu <liuj97@gmail.com> wrote:
> 
> > +	free_reserved_area((void *)start, (void *)end, -1, "initrd");
> 
> Do you mean -1 or ULONG_MAX?

No matter...  It's a poison value, not an address.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
