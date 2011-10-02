Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0EC8F9000BD
	for <linux-mm@kvack.org>; Sun,  2 Oct 2011 04:44:03 -0400 (EDT)
Received: by ywe9 with SMTP id 9so3473739ywe.14
        for <linux-mm@kvack.org>; Sun, 02 Oct 2011 01:44:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E831A79.1030402@tilera.com>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
	<4E831A79.1030402@tilera.com>
Date: Sun, 2 Oct 2011 10:44:00 +0200
Message-ID: <CAOtvUMdGeBfbLpSqonzLTT6+JUiabDjBG5bpd1_RPykt3x+5Hw@mail.gmail.com>
Subject: Re: [PATCH 0/5] Reduce cross CPU IPI interference
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Wed, Sep 28, 2011 at 3:00 PM, Chris Metcalf <cmetcalf@tilera.com> wrote:
> On 9/25/2011 4:54 AM, Gilad Ben-Yossef wrote:
>
> I strongly concur with your motivation in looking for and removing sources
> of unnecessary cross-cpu interrupts.

Thanks for the support :-)

> We have some code in our tree (not yet
> returned to the community) that tries to deal with some sources of interrupt
> jitter on tiles that are running isolcpu and want to be 100% in user space.

Yes, I think this work will benefit this kind of use case (CPU/user
space bound on a dedicated CPU)
the most, although other use cases can benefit as well (e.g. power
management with idle cores).

Btw, do you have any plan to share the patches you mentioned? it could
save me a lot of time. Not wanting to
re-invent the wheel and all that...


>> This first version creates an on_each_cpu_mask infrastructure API (derived
>> from
>> existing arch specific versions in Tile and Arm) and uses it to turn two
>> global
>> IPI invocation to per CPU group invocations.
>
> The global version looks fine; I would probably make on_each_cpu() an inline
> in the !SMP case now that you are (correctly, I suspect) disabling
> interrupts when calling the function.
>

Good point. Will do.

I will take this email as an ACK to the tile relevant changes, if that
is OK with you.

Thanks!
Gilad


-- 
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"I've seen things you people wouldn't believe. Goto statements used to
implement co-routines. I watched C structures being stored in
registers. All those moments will be lost in time... like tears in
rain... Time to die. "

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
