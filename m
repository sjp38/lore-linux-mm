Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 54F739000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 04:10:07 -0400 (EDT)
Received: by gya6 with SMTP id 6so5328126gya.14
        for <linux-mm@kvack.org>; Mon, 26 Sep 2011 01:10:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOJsxLEHHJyPnCngQceRW04PLKFa3RUQEbc3rLwiOPXa7XZNeQ@mail.gmail.com>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
	<1316940890-24138-6-git-send-email-gilad@benyossef.com>
	<CAOJsxLEHHJyPnCngQceRW04PLKFa3RUQEbc3rLwiOPXa7XZNeQ@mail.gmail.com>
Date: Mon, 26 Sep 2011 11:10:05 +0300
Message-ID: <CAOtvUMcTBhT2rWq-CYViPj1_oP1LGpb9SoSjctRRZZYPSfxWfg@mail.gmail.com>
Subject: Re: [PATCH 5/5] slub: Only IPI CPUs that have per cpu obj to flush
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>

Hi,

On Mon, Sep 26, 2011 at 9:54 AM, Pekka Enberg <penberg@cs.helsinki.fi> wrote:


>  Also, I'm somewhat unhappy about introducing
> memory allocations in memory shrinking code paths. If we really want
> to do this, can we preallocate cpumask in struct kmem_cache, for
> example?

Yes, I will.

Thanks!
Gilad.


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
