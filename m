Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 3A7696B0125
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 22:14:13 -0400 (EDT)
Received: by obhx4 with SMTP id x4so4584481obh.14
        for <linux-mm@kvack.org>; Wed, 12 Sep 2012 19:14:12 -0700 (PDT)
Date: Wed, 12 Sep 2012 19:14:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm: refactor out __alloc_contig_migrate_alloc
In-Reply-To: <1347414231-31451-1-git-send-email-minchan@kernel.org>
Message-ID: <alpine.DEB.2.00.1209121913520.22590@chino.kir.corp.google.com>
References: <1347414231-31451-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>

On Wed, 12 Sep 2012, Minchan Kim wrote:

> __alloc_contig_migrate_alloc can be used by memory-hotplug so
> refactor out(move + rename as a common name) it into
> page_isolation.c.
> 
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Wen Congyang <wency@cn.fujitsu.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
