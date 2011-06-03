Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 14ACD6B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 01:49:11 -0400 (EDT)
Received: by gwaa12 with SMTP id a12so789936gwa.14
        for <linux-mm@kvack.org>; Thu, 02 Jun 2011 22:49:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DE7D2AC.1070503@tilera.com>
References: <201106021424.p52EO91O006974@lab-17.internal.tilera.com>
	<alpine.DEB.2.00.1106021015220.18350@chino.kir.corp.google.com>
	<4DE7D2AC.1070503@tilera.com>
Date: Fri, 3 Jun 2011 08:49:10 +0300
Message-ID: <BANLkTinjCbhiwRfQ_aN5wtbYipQB6gv5AA@mail.gmail.com>
Subject: Re: [PATCH] slub: always align cpu_slab to honor cmpxchg_double requirement
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jun 2, 2011 at 9:13 PM, Chris Metcalf <cmetcalf@tilera.com> wrote:
> On 6/2/2011 1:16 PM, David Rientjes wrote:
>> On Thu, 2 Jun 2011, Chris Metcalf wrote:
>>> On an architecture without CMPXCHG_LOCAL but with DEBUG_VM enabled,
>>> the VM_BUG_ON() in __pcpu_double_call_return_bool() will cause an early
>>> panic during boot unless we always align cpu_slab properly.
>>>
>>> In principle we could remove the alignment-testing VM_BUG_ON() for
>>> architectures that don't have CMPXCHG_LOCAL, but leaving it in means
>>> that new code will tend not to break x86 even if it is introduced
>>> on another platform, and it's low cost to require alignment.
>>>
>>> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
>> Acked-by: David Rientjes <rientjes@google.com>
>>
>>> ---
>>> This needs to be pushed for 3.0 to allow arch/tile to boot.
>>> I'm happy to push it but I assume it would be better coming
>>> from an mm or percpu tree. =A0Thanks!
>>>
>> Should also be marked for stable for 2.6.39.x, right?
>
> No, in 2.6.39 the irqsafe_cpu_cmpxchg_double() was guarded under "#ifdef
> CONFIG_CMPXCHG_LOCAL". =A0Now it's not. =A0I suppose we could take the co=
mment
> change in percpu.h for 2.6.39, but it probably doesn't merit churning the
> stable tree.

Yup. Looks good. Christoph?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
