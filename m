Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 091B66B0070
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 11:26:24 -0400 (EDT)
Received: by eekb47 with SMTP id b47so3646215eek.14
        for <linux-mm@kvack.org>; Wed, 04 Jul 2012 08:26:23 -0700 (PDT)
Subject: Re: [PATCH 1/3 v2] slub: prefetch next freelist pointer in
 __slab_alloc()
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <CAOJsxLGBxeu2sE-wDT+YNyVipmXiPj7Gvmmdo-0zGmJObp2zxg@mail.gmail.com>
References: <1340389359-2407-1-git-send-email-js1304@gmail.com>
	 <1340390729-2821-1-git-send-email-js1304@gmail.com>
	 <CAOJsxLHSboF0rQdGv8bdgGtinBz5dTo+omQbUnj9on_ewzgNAQ@mail.gmail.com>
	 <CAAmzW4OdDhn5C_vfMhu3ejzzcXmCCt6r0h=nXUqKJaNYZxg8Bw@mail.gmail.com>
	 <CAOJsxLGBxeu2sE-wDT+YNyVipmXiPj7Gvmmdo-0zGmJObp2zxg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 04 Jul 2012 17:26:19 +0200
Message-ID: <1341415579.2583.2134.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: JoonSoo Kim <js1304@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Wed, 2012-07-04 at 18:08 +0300, Pekka Enberg wrote:

> That doesn't seem like that obvious win to me... Eric, Christoph?

Its the slow path. I am not convinced its useful on real workloads (not
a benchmark)

I mean, if a workload hits badly slow path, some more important work
should be done to avoid this at a higher level.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
