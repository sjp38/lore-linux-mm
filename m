Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 31A136B0088
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 16:16:11 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id d23so1314185fga.8
        for <linux-mm@kvack.org>; Tue, 24 Nov 2009 13:16:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1259096519.4531.1809.camel@laptop>
References: <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com>
	 <4B0ADEF5.9040001@cs.helsinki.fi> <1259080406.4531.1645.camel@laptop>
	 <20091124170032.GC6831@linux.vnet.ibm.com>
	 <1259082756.17871.607.camel@calx> <1259086459.4531.1752.camel@laptop>
	 <1259090615.17871.696.camel@calx> <1259095580.4531.1788.camel@laptop>
	 <1259096004.17871.716.camel@calx> <1259096519.4531.1809.camel@laptop>
Date: Tue, 24 Nov 2009 23:16:08 +0200
Message-ID: <84144f020911241316q704d0677m9fe9e2689948903b@mail.gmail.com>
Subject: Re: lockdep complaints in slab allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Matt Mackall <mpm@selenic.com>, paulmck@linux.vnet.ibm.com, linux-mm@kvack.org, cl@linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 24, 2009 at 11:01 PM, Peter Zijlstra <peterz@infradead.org> wrote:
>> If there's a proposal here, it's not clear what it is.
>
> Merge SLQB and rm mm/sl[ua]b.c include/linux/sl[ua]b.h for .33-rc1
>
> As long as people have a choice they'll not even try new stuff and if
> they do they'll change to the old one as soon as they find an issue, not
> even bothering to report, let alone expend effort fixing it.

Oh, no, SLQB is by no means stable enough for the general public. And
it doesn't even have all the functionality SLAB and SLUB does (cpusets
come to mind).

If people want to really help us getting out of this mess, please take
a stab at fixing any of the outstanding performance regressions for
either SLQB or SLUB. David's a great source if you're interested in
knowing where to look. The only big regression for SLUB is the Intel
TPC benchmark thingy that nobody (except Intel folks) really has
access to. SLQB doesn't suffer from that because Nick had some
performance testing help from Intel IIRC.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
