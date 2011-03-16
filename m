Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0D1558D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 02:23:52 -0400 (EDT)
Received: by gxk23 with SMTP id 23so707607gxk.14
        for <linux-mm@kvack.org>; Tue, 15 Mar 2011 23:23:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1300244238.3128.420.camel@calx>
References: <20110316022804.27676.qmail@science.horizon.com>
	<1300244238.3128.420.camel@calx>
Date: Wed, 16 Mar 2011 08:23:50 +0200
Message-ID: <AANLkTimZRnaf6C-vOkkM-uhVVzn8NO8_V9Xb16rN7BKK@mail.gmail.com>
Subject: Re: [PATCH 0/8] mm/slub: Add SLUB_RANDOMIZE support
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: George Spelvin <linux@horizon.com>, penberg@cs.helsinki.fi, herbert@gondor.apana.org.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Dan Rosenberg <drosenberg@vsecurity.com>, Linus Torvalds <torvalds@linux-foundation.org>

Hi Matt,

On Sun, 2011-03-13 at 20:20 -0400, George Spelvin wrote:
>> As a followup to the "[PATCH] Make /proc/slabinfo 0400" thread, this
>> is a patch series to randomize the order of object allocations within
>> a page. =A0It can be extended to SLAB and SLOB if desired. =A0Mostly it'=
s
>> for benchmarking and discussion.

On Wed, Mar 16, 2011 at 4:57 AM, Matt Mackall <mpm@selenic.com> wrote:
> I've spent a while thinking about this over the past few weeks, and I
> really don't think it's productive to try to randomize the allocators.
> It provides negligible defense and just makes life harder for kernel
> hackers.

If it's an optional feature and the impact on the code is low (as it
seems to be), what's the downside? Combined with disabling SLUB's slab
merging, randomization should definitely make it more difficult to
have full control over a full slab. I don't know how much defense it
will provide but I think randomization is definitely an option worth
exploring.

> (And you definitely can't randomize SLOB like this.)

No, you can't but heap exploits like the one we discuss are slightly
harder with SLOB anyway, no?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
