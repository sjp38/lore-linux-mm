Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 37C2D9000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 04:43:56 -0400 (EDT)
Received: by ywe9 with SMTP id 9so5529695ywe.14
        for <linux-mm@kvack.org>; Mon, 26 Sep 2011 01:43:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1317021659.9084.51.camel@twins>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
	<1317021659.9084.51.camel@twins>
Date: Mon, 26 Sep 2011 11:43:54 +0300
Message-ID: <CAOtvUMeBRv4OO9DcYJgj07_MnbfL4jT24D2YQfQN8Srj4CEzzg@mail.gmail.com>
Subject: Re: [PATCH 0/5] Reduce cross CPU IPI interference
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Mon, Sep 26, 2011 at 10:20 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> On Sun, 2011-09-25 at 11:54 +0300, Gilad Ben-Yossef wrote:
>> This first version creates an on_each_cpu_mask infrastructure API
>
> But we already have the existing smp_call_function_many() doing that.

I might be wrong but my understanding is that smp_call_function_many()
does not invoke the IPI handler on the current processor. The original
code I replaced uses on_each_cpu() which does, so I figured a wrapper
was in order and then I discovered the same wrapper in arch specific
code.

> The on_each_cpu() thing is mostly a hysterical relic and could be
> completely depricated

Wont this require each caller to call smp_call_function_* and then
check to see if it needs to also invoke the IPI handler locally ? I
thought that was the reason for on_each_cpu existence... What have I
missed?

Thanks,
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
