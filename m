Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id B39456B005A
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 13:57:25 -0400 (EDT)
Date: Wed, 8 Aug 2012 12:56:13 -0500 (CDT)
From: "Christoph Lameter (Open Source)" <cl@linux.com>
Subject: Re: Common10 [13/20] Move kmem_cache allocations into common code.
In-Reply-To: <50226ED0.9080404@parallels.com>
Message-ID: <alpine.DEB.2.02.1208081255420.7756@greybox.home>
References: <20120803192052.448575403@linux.com> <20120803192155.337884418@linux.com> <50226ED0.9080404@parallels.com>
MIME-Version: 1.0
Content-Type: MULTIPART/Mixed; BOUNDARY=------------050509080504020108020402
Content-ID: <alpine.DEB.2.02.1208081255421.7756@greybox.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--------------050509080504020108020402
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.02.1208081255422.7756@greybox.home>

On Wed, 8 Aug 2012, Glauber Costa wrote:

> On 08/03/2012 11:21 PM, Christoph Lameter wrote:
> > Shift the allocations to common code. That way the allocation
> > and freeing of the kmem_cache structures is handled by common code.
> >
> > V1-V2: Use the return code from setup_cpucache() in slab instead of returning -ENOSPC
>
> This patch doesn't even boot! (slub)

Yup the test in create kmalloc slab needs to do the opposite. A later
patch removes that code. Fixed.

--------------050509080504020108020402
Content-Type: TEXT/PLAIN; CHARSET=UTF-8; NAME=kmalloc-bug
Content-ID: <alpine.DEB.2.02.1208081255423.7756@greybox.home>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME=kmalloc-bug

[    0.000000] Memory: 989060k/1048568k available (5273k kernel code, 452k absent, 59056k reserved, 5916k data, 932k init)
[    0.000000] Kernel panic - not syncing: Creation of kmalloc slab kmalloc-96 size=96 failed.
[    0.000000] 
[    0.000000] Pid: 0, comm: swapper Not tainted 3.5.0-rc1+ #3
[    0.000000] Call Trace:
[    0.000000]  [<ffffffff815116c2>] panic+0xbd/0x1cd
[    0.000000]  [<ffffffff81b2673f>] create_kmalloc_cache+0x54/0x70
[    0.000000]  [<ffffffff81b26897>] kmem_cache_init+0x13c/0x2c2
[    0.000000]  [<ffffffff81b049d0>] start_kernel+0x1ee/0x3d3
[    0.000000]  [<ffffffff81b045ea>] ? repair_env_string+0x5a/0x5a
[    0.000000]  [<ffffffff81b042d6>] x86_64_start_reservations+0xb1/0xb5
[    0.000000]  [<ffffffff81b043d8>] x86_64_start_kernel+0xfe/0x10b
[    0.000000] ------------[ cut here ]------------
[    0.000000] WARNING: at kernel/lockdep.c:2585 trace_hardirqs_on_caller+0xdf/0x173()
[    0.000000] Hardware name: Bochs
[    0.000000] Modules linked in:
[    0.000000] Pid: 0, comm: swapper Not tainted 3.5.0-rc1+ #3
[    0.000000] Call Trace:
[    0.000000]  [<ffffffff81047f89>] warn_slowpath_common+0x83/0x9c
[    0.000000]  [<ffffffff8151178b>] ? panic+0x186/0x1cd
[    0.000000]  [<ffffffff81047fbc>] warn_slowpath_null+0x1a/0x1c
[    0.000000]  [<ffffffff81093e53>] trace_hardirqs_on_caller+0xdf/0x173
[    0.000000]  [<ffffffff81093ef4>] trace_hardirqs_on+0xd/0xf
[    0.000000]  [<ffffffff8151178b>] panic+0x186/0x1cd
[    0.000000]  [<ffffffff81b2673f>] create_kmalloc_cache+0x54/0x70
[    0.000000]  [<ffffffff81b26897>] kmem_cache_init+0x13c/0x2c2
[    0.000000]  [<ffffffff81b049d0>] start_kernel+0x1ee/0x3d3
[    0.000000]  [<ffffffff81b045ea>] ? repair_env_string+0x5a/0x5a
[    0.000000]  [<ffffffff81b042d6>] x86_64_start_reservations+0xb1/0xb5
[    0.000000]  [<ffffffff81b043d8>] x86_64_start_kernel+0xfe/0x10b
[    0.000000] ---[ end trace a7919e7f17c0a725 ]---

--------------050509080504020108020402--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
