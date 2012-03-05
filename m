Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 2F3976B0092
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 15:04:05 -0500 (EST)
Message-ID: <4F551BE6.4050509@redhat.com>
Date: Mon, 05 Mar 2012 15:02:46 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -v2] mm: SLAB Out-of-memory diagnostics
References: <20120305181041.GA9829@x61.redhat.com>
In-Reply-To: <20120305181041.GA9829@x61.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Josef Bacik <josef@redhat.com>, David Rientjes <rientjes@google.com>

On 03/05/2012 01:10 PM, Rafael Aquini wrote:
> Following the example at mm/slub.c, add out-of-memory diagnostics to the
> SLAB allocator to help on debugging certain OOM conditions.
>
> An example print out looks like this:
>
>    <snip page allocator out-of-memory message>
>    SLAB: Unable to allocate memory on node 0 (gfp=0x11200)
>       cache: bio-0, object size: 192, order: 0
>       node0: slabs: 3/3, objs: 60/60, free: 0
>
> Signed-off-by: Rafael Aquini<aquini@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
