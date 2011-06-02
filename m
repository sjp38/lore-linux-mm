Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 62AED900001
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 14:13:04 -0400 (EDT)
Message-ID: <4DE7D2AC.1070503@tilera.com>
Date: Thu, 2 Jun 2011 14:13:00 -0400
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: always align cpu_slab to honor cmpxchg_double requirement
References: <201106021424.p52EO91O006974@lab-17.internal.tilera.com> <alpine.DEB.2.00.1106021015220.18350@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1106021015220.18350@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 6/2/2011 1:16 PM, David Rientjes wrote:
> On Thu, 2 Jun 2011, Chris Metcalf wrote:
>> On an architecture without CMPXCHG_LOCAL but with DEBUG_VM enabled,
>> the VM_BUG_ON() in __pcpu_double_call_return_bool() will cause an early
>> panic during boot unless we always align cpu_slab properly.
>>
>> In principle we could remove the alignment-testing VM_BUG_ON() for
>> architectures that don't have CMPXCHG_LOCAL, but leaving it in means
>> that new code will tend not to break x86 even if it is introduced
>> on another platform, and it's low cost to require alignment.
>>
>> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
> Acked-by: David Rientjes <rientjes@google.com>
>
>> ---
>> This needs to be pushed for 3.0 to allow arch/tile to boot.
>> I'm happy to push it but I assume it would be better coming
>> from an mm or percpu tree.  Thanks!
>>
> Should also be marked for stable for 2.6.39.x, right?

No, in 2.6.39 the irqsafe_cpu_cmpxchg_double() was guarded under "#ifdef
CONFIG_CMPXCHG_LOCAL".  Now it's not.  I suppose we could take the comment
change in percpu.h for 2.6.39, but it probably doesn't merit churning the
stable tree.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
