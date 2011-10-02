Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id E673C9000BD
	for <linux-mm@kvack.org>; Sun,  2 Oct 2011 10:58:51 -0400 (EDT)
Message-ID: <4E887C23.4030600@tilera.com>
Date: Sun, 2 Oct 2011 10:58:43 -0400
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Reduce cross CPU IPI interference
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com> <4E831A79.1030402@tilera.com> <CAOtvUMdGeBfbLpSqonzLTT6+JUiabDjBG5bpd1_RPykt3x+5Hw@mail.gmail.com>
In-Reply-To: <CAOtvUMdGeBfbLpSqonzLTT6+JUiabDjBG5bpd1_RPykt3x+5Hw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On 10/2/2011 4:44 AM, Gilad Ben-Yossef wrote:
>> We have some code in our tree (not yet
>> returned to the community) that tries to deal with some sources of interrupt
>> jitter on tiles that are running isolcpu and want to be 100% in user space.
> Yes, I think this work will benefit this kind of use case (CPU/user
> space bound on a dedicated CPU)
> the most, although other use cases can benefit as well (e.g. power
> management with idle cores).
>
> Btw, do you have any plan to share the patches you mentioned? it could
> save me a lot of time. Not wanting to
> re-invent the wheel and all that...

I'd like to, but getting the patch put together cleanly is still on my list
behind a number of other things (glibc community return, kernel catch-up
with a backlog of less controversial changes, customer crises, enhancements
targeted to forthcoming releases, etc.; I'm sure you know the drill...)

>>> This first version creates an on_each_cpu_mask infrastructure API (derived
>>> from
>>> existing arch specific versions in Tile and Arm) and uses it to turn two
>>> global
>>> IPI invocation to per CPU group invocations.
>> The global version looks fine; I would probably make on_each_cpu() an inline
>> in the !SMP case now that you are (correctly, I suspect) disabling
>> interrupts when calling the function.
>>
> Good point. Will do.
>
> I will take this email as an ACK to the tile relevant changes, if that
> is OK with you.

Yes, definitely.

Acked-by: Chris Metcalf <cmetcalf@tilera.com>

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
