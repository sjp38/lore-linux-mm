Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 563D96B0062
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 13:42:06 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so983472fgg.4
        for <linux-mm@kvack.org>; Tue, 03 Feb 2009 10:42:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.1.10.0902031217390.17910@qirst.com>
References: <20090114155923.GC1616@wotan.suse.de>
	 <20090123155307.GB14517@wotan.suse.de>
	 <alpine.DEB.1.10.0901261225240.1908@qirst.com>
	 <200902031253.28078.nickpiggin@yahoo.com.au>
	 <alpine.DEB.1.10.0902031217390.17910@qirst.com>
Date: Tue, 3 Feb 2009 20:42:04 +0200
Message-ID: <84144f020902031042i31eaec14v53a0e7a203acd28b@mail.gmail.com>
Subject: Re: [patch] SLQB slab allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On Tue, Feb 3, 2009 at 7:33 PM, Christoph Lameter
<cl@linux-foundation.org> wrote:
>> > Trimming through water marks and allocating memory from the page allocator
>> > is going to be very frequent if you continually allocate on one processor
>> > and free on another.
>>
>> Um yes, that's the point. But you previously claimed that it would just
>> grow unconstrained. Which is obviously wrong. So I don't understand what
>> your point is.
>
> It will grow unconstrained if you elect to defer queue processing. That
> was what we discussed.

Well, the slab_hiwater() check in __slab_free() of mm/slqb.c will cap
the size of the queue. But we do the same thing in SLAB with
alien->limit in cache_free_alien() and ac->limit in __cache_free(). So
I'm not sure what you mean when you say that the queues will "grow
unconstrained" (in either of the allocators). Hmm?

                               Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
