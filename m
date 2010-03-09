Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 99BA36B00CF
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 15:04:13 -0500 (EST)
Message-ID: <4B96A9B2.8070806@cs.helsinki.fi>
Date: Tue, 09 Mar 2010 22:04:02 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: mm: Do not iterate over NR_CPUS in __zone_pcp_update()
References: <alpine.LFD.2.00.1003081018070.22855@localhost.localdomain> <84144f021003080529w1b20c08dmf6871bd46381bc71@mail.gmail.com> <4B95AD17.2030106@kernel.org> <alpine.DEB.2.00.1003090910200.28897@router.home>
In-Reply-To: <alpine.DEB.2.00.1003090910200.28897@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 9 Mar 2010, Tejun Heo wrote:
> 
>> Yeap, that's buggy.
>>
>> Acked-by: Tejun Heo <tj@kernel.org>
>>
>> I suppose this would go through the mm tree?
> 
> As you said: Its a bug so it needs to be applied to upstream.

Sure but someone needs to pick up the patch and send it to Linus. Andrew?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
