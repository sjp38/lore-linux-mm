Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8E5306B0083
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 13:16:40 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p52HGcL9011215
	for <linux-mm@kvack.org>; Thu, 2 Jun 2011 10:16:38 -0700
Received: from pwj9 (pwj9.prod.google.com [10.241.219.73])
	by kpbe19.cbf.corp.google.com with ESMTP id p52HGXAR019627
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 2 Jun 2011 10:16:37 -0700
Received: by pwj9 with SMTP id 9so641505pwj.20
        for <linux-mm@kvack.org>; Thu, 02 Jun 2011 10:16:32 -0700 (PDT)
Date: Thu, 2 Jun 2011 10:16:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: always align cpu_slab to honor cmpxchg_double
 requirement
In-Reply-To: <201106021424.p52EO91O006974@lab-17.internal.tilera.com>
Message-ID: <alpine.DEB.2.00.1106021015220.18350@chino.kir.corp.google.com>
References: <201106021424.p52EO91O006974@lab-17.internal.tilera.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 2 Jun 2011, Chris Metcalf wrote:

> On an architecture without CMPXCHG_LOCAL but with DEBUG_VM enabled,
> the VM_BUG_ON() in __pcpu_double_call_return_bool() will cause an early
> panic during boot unless we always align cpu_slab properly.
> 
> In principle we could remove the alignment-testing VM_BUG_ON() for
> architectures that don't have CMPXCHG_LOCAL, but leaving it in means
> that new code will tend not to break x86 even if it is introduced
> on another platform, and it's low cost to require alignment.
> 
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>

Acked-by: David Rientjes <rientjes@google.com>

> ---
> This needs to be pushed for 3.0 to allow arch/tile to boot.
> I'm happy to push it but I assume it would be better coming
> from an mm or percpu tree.  Thanks!
> 

Should also be marked for stable for 2.6.39.x, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
