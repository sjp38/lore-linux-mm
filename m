Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 2D5736B005A
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 09:51:19 -0400 (EDT)
Message-ID: <50226ED0.9080404@parallels.com>
Date: Wed, 8 Aug 2012 17:51:12 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common10 [13/20] Move kmem_cache allocations into common code.
References: <20120803192052.448575403@linux.com> <20120803192155.337884418@linux.com>
In-Reply-To: <20120803192155.337884418@linux.com>
Content-Type: multipart/mixed;
	boundary="------------050509080504020108020402"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

--------------050509080504020108020402
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

On 08/03/2012 11:21 PM, Christoph Lameter wrote:
> Shift the allocations to common code. That way the allocation
> and freeing of the kmem_cache structures is handled by common code.
> 
> V1-V2: Use the return code from setup_cpucache() in slab instead of returning -ENOSPC

This patch doesn't even boot! (slub)



--------------050509080504020108020402
Content-Type: text/plain; charset="UTF-8"; name="kmalloc-bug"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="kmalloc-bug"

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
