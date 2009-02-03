Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A10C06B0062
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 13:47:50 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so985034fgg.4
        for <linux-mm@kvack.org>; Tue, 03 Feb 2009 10:47:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <84144f020902031042i31eaec14v53a0e7a203acd28b@mail.gmail.com>
References: <20090114155923.GC1616@wotan.suse.de>
	 <20090123155307.GB14517@wotan.suse.de>
	 <alpine.DEB.1.10.0901261225240.1908@qirst.com>
	 <200902031253.28078.nickpiggin@yahoo.com.au>
	 <alpine.DEB.1.10.0902031217390.17910@qirst.com>
	 <84144f020902031042i31eaec14v53a0e7a203acd28b@mail.gmail.com>
Date: Tue, 3 Feb 2009 20:47:48 +0200
Message-ID: <84144f020902031047o2e117652w28886efb495688c4@mail.gmail.com>
Subject: Re: [patch] SLQB slab allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 3, 2009 at 8:42 PM, Pekka Enberg <penberg@cs.helsinki.fi> wrote:
>> It will grow unconstrained if you elect to defer queue processing. That
>> was what we discussed.
>
> Well, the slab_hiwater() check in __slab_free() of mm/slqb.c will cap
> the size of the queue. But we do the same thing in SLAB with
> alien->limit in cache_free_alien() and ac->limit in __cache_free(). So
> I'm not sure what you mean when you say that the queues will "grow
> unconstrained" (in either of the allocators). Hmm?

That said, I can imagine a worst-case scenario where a queue with N
objects is pinning N mostly empty slabs. As soon as we hit the
periodical flush, we might need to do tons of work. That's pretty hard
to control with watermarks as well as the scenario is solely dependent
on allocation/free patterns.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
