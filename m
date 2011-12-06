Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id D54316B004F
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 01:48:51 -0500 (EST)
Message-ID: <4EDDBC97.8040900@redhat.com>
Date: Tue, 06 Dec 2011 01:56:23 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: vmalloc: Check for page allocation failure before
 vmlist insertion
References: <20111205140750.GB5070@suse.de>
In-Reply-To: <20111205140750.GB5070@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Namhyung Kim <namhyung@gmail.com>, Luciano Chavez <lnx1138@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/05/2011 09:07 AM, Mel Gorman wrote:
> Commit [f5252e00: mm: avoid null pointer access in vm_struct via
> /proc/vmallocinfo] adds newly allocated vm_structs to the vmlist
> after it is fully initialised. Unfortunately, it did not check that
> __vmalloc_area_node() successfully populated the area. In the event
> of allocation failure, the vmalloc area is freed but the pointer to
> freed memory is inserted into the vmlist leading to a a crash later
> in get_vmalloc_info().
>
> This patch adds a check for ____vmalloc_area_node() failure within
> __vmalloc_node_range. It does not use "goto fail" as in the previous
> error path as a warning was already displayed by __vmalloc_area_node()
> before it called vfree in its failure path.
>
> Credit goes to Luciano Chavez for doing all the real work of
> identifying exactly where the problem was.
>
> If accepted, this should be considered a -stable candidate.
>
> Reported-and-tested-by: Luciano Chavez<lnx1138@linux.vnet.ibm.com>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
