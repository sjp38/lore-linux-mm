Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id CF16A6B002B
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 15:06:17 -0500 (EST)
Date: Fri, 9 Nov 2012 20:06:16 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v6 25/29] memcg/sl[au]b: shrink dead caches
In-Reply-To: <20121108144043.baf9f2e5.akpm@linux-foundation.org>
Message-ID: <0000013ae6c7ac4a-138f8469-5fa2-4a2e-b569-0717659f0c9e-000000@email.amazonses.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com> <1351771665-11076-26-git-send-email-glommer@parallels.com> <20121105164813.2eba5ecb.akpm@linux-foundation.org> <509A0A04.2030503@parallels.com> <20121106231627.3610c908.akpm@linux-foundation.org>
 <509A2849.9090509@parallels.com> <20121107144612.e822986f.akpm@linux-foundation.org> <0000013ae1050e6f-7f908e0b-720a-4e68-a275-e5086a4f5c74-000000@email.amazonses.com> <20121108112120.fc964c29.akpm@linux-foundation.org> <509C32B4.7050105@parallels.com>
 <20121108144043.baf9f2e5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>, Robert Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Brown, Len" <len.brown@intel.com>

On Thu, 8 Nov 2012, Andrew Morton wrote:

> I'd still like to give ACPI a thwap.  That kmem_cache_shrink() in
> drivers/acpi/osl.c was added unchangelogged in a megapatch
> (73459f73e5d1602c59) so it's a mystery.  Cc's optimistically added.

It does not hurt though and releasing cache objects when there will be no
objects added and removed from a slab cache is a good thing to do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
