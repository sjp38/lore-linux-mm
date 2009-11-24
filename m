Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A3A386B0078
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 16:19:36 -0500 (EST)
Received: by fxm9 with SMTP id 9so7503968fxm.10
        for <linux-mm@kvack.org>; Tue, 24 Nov 2009 13:19:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1259097150.4531.1822.camel@laptop>
References: <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com>
	 <20091124170032.GC6831@linux.vnet.ibm.com>
	 <1259082756.17871.607.camel@calx> <1259086459.4531.1752.camel@laptop>
	 <1259090615.17871.696.camel@calx> <1259095580.4531.1788.camel@laptop>
	 <1259096004.17871.716.camel@calx> <1259096519.4531.1809.camel@laptop>
	 <alpine.DEB.2.00.0911241302370.6593@chino.kir.corp.google.com>
	 <1259097150.4531.1822.camel@laptop>
Date: Tue, 24 Nov 2009 23:19:33 +0200
Message-ID: <84144f020911241319g24dbfbd0j9a27698539404e36@mail.gmail.com>
Subject: Re: lockdep complaints in slab allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, paulmck@linux.vnet.ibm.com, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 24, 2009 at 11:12 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Tue, 2009-11-24 at 13:03 -0800, David Rientjes wrote:
>> On Tue, 24 Nov 2009, Peter Zijlstra wrote:
>>
>> > Merge SLQB and rm mm/sl[ua]b.c include/linux/sl[ua]b.h for .33-rc1
>> >
>>
>> slqb still has a 5-10% performance regression compared to slab for
>> benchmarks such as netperf TCP_RR on machines with high cpu counts,
>> forcing that type of regression isn't acceptable.
>
> Having _4_ slab allocators is equally unacceptable.

The whole idea behind merging SLQB is to see if it can replace SLAB.
If it can't do that in few kernel releases, we're pulling it out. It's
as simple as that.

And if SLQB can replace SLAB, then we start to talk about replacing SLUB too...

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
