Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 71AF26B0069
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 05:03:32 -0400 (EDT)
Message-ID: <50656715.1020303@parallels.com>
Date: Fri, 28 Sep 2012 13:00:05 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: CK1 [00/13] [RFC] Sl[auo]b: Common kmalloc caches V1
References: <0000013a03fe75d9-fa42a2fe-0742-47bd-99ee-5d2886e30436-000000@email.amazonses.com>
In-Reply-To: <0000013a03fe75d9-fa42a2fe-0742-47bd-99ee-5d2886e30436-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Fengguang Wu <fengguang.wu@intel.com>

On 09/26/2012 11:12 PM, Christoph Lameter wrote:
> This patchset cleans up the bootstrap of the allocators
> and creates a common function to set up the
> kmalloc array. The results are more common
> data structures that will simplify further work
> on having common functions for all allocators.
> 

The patchset looks good in general, and the few things that need to be
fixed that I could spot in this review I've sent already.

It seems to touch less bug-prone things than your last round, which is
good. Still, given all the small problems we had, I would insist this
should get a round of build & boot testing to make sure they don't
happen again.

Thankfully, we now have Fengguang's marvelous 0-day test system that
should be able to find all that.

For simplicity, I've uploaded your series to my "slab-common/kmalloc"
branch at:

git://git.kernel.org/pub/scm/linux/kernel/git/glommer/memcg.git

I'll let you know if it spills anything, and you can then fold together
with my comments in v2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
