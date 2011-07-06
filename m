Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F3E389000C2
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 16:21:14 -0400 (EDT)
Date: Wed, 6 Jul 2011 13:20:55 -0700 (PDT)
From: david@lang.hm
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory
 Power Management
In-Reply-To: <CAOJsxLHQP=-srK_uYYBsPb7+rUBnPZG7bzwtCd-rRaQa4ikUFg@mail.gmail.com>
Message-ID: <alpine.DEB.2.02.1107061318190.2535@asgard.lang.hm>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com> <20110629130038.GA7909@in.ibm.com> <CAOJsxLHQP=-srK_uYYBsPb7+rUBnPZG7bzwtCd-rRaQa4ikUFg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Ankita Garg <ankita@in.ibm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, Dave Hansen <dave@linux.vnet.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Matthew Garrett <mjg59@srcf.ucam.org>, Arjan van de Ven <arjan@infradead.org>, Christoph Lameter <cl@linux.com>

On Wed, 6 Jul 2011, Pekka Enberg wrote:

> Why does the allocator need to know about address boundaries? Why
> isn't it enough to make the page allocator and reclaim policies favor using
> memory from lower addresses as aggressively as possible? That'd mean
> we'd favor the first memory banks and could keep the remaining ones
> powered off as much as possible.
>
> IOW, why do we need to support scenarios such as this:
>
>   bank 0     bank 1   bank 2    bank3
> | online  | offline | online  | offline |

I believe that there are memory allocations that cannot be moved after 
they are made (think about regions allocated to DMA from hardware where 
the hardware has already been given the address space to DMA into)

As a result, you may not be able to take bank 2 offline, so your option is 
to either leave banks 0-2 all online, or support emptying bank 1 and 
taking it offline.

David Lang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
