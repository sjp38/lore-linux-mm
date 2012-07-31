Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id F0E986B005A
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 02:05:40 -0400 (EDT)
Received: by wibhq4 with SMTP id hq4so2095874wib.8
        for <linux-mm@kvack.org>; Mon, 30 Jul 2012 23:05:38 -0700 (PDT)
Date: Tue, 31 Jul 2012 09:05:36 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH TRIVIAL] mm: Fix build warning in kmem_cache_create()
In-Reply-To: <alpine.DEB.2.00.1207301904520.24929@chino.kir.corp.google.com>
Message-ID: <alpine.LFD.2.02.1207310904370.2380@tux.localdomain>
References: <1342221125.17464.8.camel@lorien2> <CAOJsxLGjnMxs9qERG5nCfGfcS3jy6Rr54Ac36WgVnOtP_pDYgQ@mail.gmail.com> <alpine.DEB.2.00.1207301255320.24196@chino.kir.corp.google.com> <CAOJsxLHw8G0ChnOeBv1nNr3tqNPPjdnkY=RStyo3rRqC1bdDAA@mail.gmail.com>
 <alpine.DEB.2.00.1207301904520.24929@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: shuah.khan@hp.com, cl@linux.com, glommer@parallels.com, js1304@gmail.com, shuahkhan@gmail.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, 30 Jul 2012, David Rientjes wrote:
> So much for compromise, I thought we had agreed that at least some of the 
> checks for !name, in_interrupt() or bad size values should be moved out 
> from under the #ifdef CONFIG_DEBUG_VM, but this wasn't done.  This 
> discussion would be irrelevent if we actually did what we talked about.

I didn't want to change the checks at the last minute and invalidate 
testing in linux-next but I'm more than happy to merge such a patch when 
the merge window closes.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
