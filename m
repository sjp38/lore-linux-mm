Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id D59616B004A
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 00:06:58 -0500 (EST)
Received: by obbta14 with SMTP id ta14so8352481obb.14
        for <linux-mm@kvack.org>; Tue, 06 Mar 2012 21:06:57 -0800 (PST)
Message-ID: <4F56ECE6.4010100@gmail.com>
Date: Wed, 07 Mar 2012 13:06:46 +0800
From: Cong Wang <xiyou.wangcong@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH -v2] mm: SLAB Out-of-memory diagnostics
References: <20120305181041.GA9829@x61.redhat.com>
In-Reply-To: <20120305181041.GA9829@x61.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>, David Rientjes <rientjes@google.com>

On 03/06/2012 02:10 AM, Rafael Aquini wrote:
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

Nitpick:

What about "node: 0" instead of "node0: " ?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
