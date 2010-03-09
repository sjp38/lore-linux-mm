Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C27CD6B00A0
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 21:06:49 -0500 (EST)
Message-ID: <4B95AD17.2030106@kernel.org>
Date: Tue, 09 Mar 2010 11:06:15 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: mm: Do not iterate over NR_CPUS in __zone_pcp_update()
References: <alpine.LFD.2.00.1003081018070.22855@localhost.localdomain> <84144f021003080529w1b20c08dmf6871bd46381bc71@mail.gmail.com>
In-Reply-To: <84144f021003080529w1b20c08dmf6871bd46381bc71@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On 03/08/2010 10:29 PM, Pekka Enberg wrote:
> On Mon, Mar 8, 2010 at 11:21 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
>> __zone_pcp_update() iterates over NR_CPUS instead of limiting the
>> access to the possible cpus. This might result in access to
>> uninitialized areas as the per cpu allocator only populates the per
>> cpu memory for possible cpus.
>>
>> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> 
> Looks OK to me.
> 
> Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

Yeap, that's buggy.

Acked-by: Tejun Heo <tj@kernel.org>

I suppose this would go through the mm tree?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
