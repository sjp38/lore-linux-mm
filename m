Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 4C9286B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 08:02:54 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so4350790ied.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 05:02:53 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 22 Oct 2012 09:02:53 -0300
Message-ID: <CALF0-+U+=P4x3TMrKaXeVQ=Z87kzazoUbJMeCkGW97PyY9CH1g@mail.gmail.com>
Subject: [PATCH 0/2] mm/slob: Some more cleanups
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Tim Bird <tim.bird@am.sony.com>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Christoph Lameter <cl@linux.com>

A couple more slob patches brought to you by the CELF project:

"Kernel dynamic memory allocation tracking and reduction" [1].

The first replaces put_page by __free_pages and it's analogous
to a recent change made at slub.
The other sets zone state to obtain slab information at /proc/meminfo.

If you feel this changes is against the minimalistic spirit of SLOB,
let me know. Any other feedback or flames, are as always welcome.

These patches apply cleanly to Pekka's slab/next or slab/for-linus.

Ezequiel Garcia (2):
 mm/slob: Use free_page instead of put_page for page-size kmalloc allocations
 mm/slob: Mark zone page state to get slab usage at /proc/meminfo

 mm/slob.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

Thanks!

    Ezequiel

[1] http://elinux.org/Kernel_dynamic_memory_allocation_tracking_and_reduction

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
