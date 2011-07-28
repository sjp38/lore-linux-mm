Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F35946B0169
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 06:40:48 -0400 (EDT)
Received: by fxg9 with SMTP id 9so1499076fxg.14
        for <linux-mm@kvack.org>; Thu, 28 Jul 2011 03:40:44 -0700 (PDT)
Date: Thu, 28 Jul 2011 13:40:36 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [GIT PULL] SLAB changes for v3.1-rc0
In-Reply-To: <1311576942.6669.20.camel@edumazet-laptop>
Message-ID: <alpine.DEB.2.00.1107281337470.2841@tiger>
References: <alpine.DEB.2.00.1107221108190.2996@tiger> <1311576942.6669.20.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1827813833-1311849641=:2841"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: torvalds@linux-foundation.org, cl@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1827813833-1311849641=:2841
Content-Type: TEXT/PLAIN; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8BIT

Le vendredi 22 juillet 2011 A  11:08 +0300, Pekka Enberg a A(C)crit :
>> Here's batch of slab/slub/slob changes accumulated over the past few months.
>> The biggest changes are alignment unification from Christoph Lameter and SLUB
>> debugging improvements from Ben Greear. Also notable is SLAB 'struct
>> kmem_cache' shrinkage from Eric Dumazet that helps large SMP systems.

On Mon, 25 Jul 2011, Eric Dumazet wrote:
>> Please note that the SLUB lockless slowpath patches will be sent in a separate
>> pull request.
>>
>>                          Pekka
>
> Hi Pekka
>
> Could we also merge in 3.1 following "simple enough" patch ?
>
> Thanks
>
> [PATCH] slab: remove one NR_CPUS dependency
>
> Reduce high order allocations in do_tune_cpucache() for some setups.
> (NR_CPUS=4096 -> we need 64KB)
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Acked-by: Christoph Lameter <cl@linux.com>
> CC: Pekka Enberg <penberg@kernel.org>

Sorry for the delay. I applied the patch and will send it to Linus within 
few days.

 			Pekka
--8323329-1827813833-1311849641=:2841--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
