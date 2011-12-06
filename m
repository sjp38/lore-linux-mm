Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 7D13B6B005C
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 15:26:06 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so3483093vbb.14
        for <linux-mm@kvack.org>; Tue, 06 Dec 2011 12:26:05 -0800 (PST)
Date: Tue, 6 Dec 2011 12:26:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: vmalloc: Check for page allocation failure before
 vmlist insertion
In-Reply-To: <20111205140750.GB5070@suse.de>
Message-ID: <alpine.DEB.2.00.1112061225380.28251@chino.kir.corp.google.com>
References: <20111205140750.GB5070@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Namhyung Kim <namhyung@gmail.com>, Luciano Chavez <lnx1138@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 5 Dec 2011, Mel Gorman wrote:

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

Right, for 3.1.x.

> Reported-and-tested-by: Luciano Chavez <lnx1138@linux.vnet.ibm.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
