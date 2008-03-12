Received: by wr-out-0506.google.com with SMTP id c30so2021205wra.14
        for <linux-mm@kvack.org>; Wed, 12 Mar 2008 10:10:13 -0700 (PDT)
Message-ID: <6934efce0803121010y6f541a51tf0cd18399160dace@mail.gmail.com>
Date: Wed, 12 Mar 2008 10:10:12 -0700
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: [patch 0/7] [rfc] VM_MIXEDMAP, pte_special, xip work
In-Reply-To: <20080311213525.a5994894.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080311104653.995564000@nick.local0.net>
	 <20080311213525.a5994894.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

>  umm, could we have some executive summary about what this is all supposed
>  to achieve?  I can see what each patch does, but what's the overall result?

We talked about this a couple years back at the Embedded Linux
Conference.  In response to my whining about how ugly XIP hacks were
preventing me from merging my AXFS filesystem, you said, "We have an
XIP framework. Why don't you fix that?"

This is fixing the the XIP framework.

The old XIP framework just didn't work for embedded, mostly because it
was page based.  Nick decided to help and proposed a way to rework the
XIP framework to be pfn based instead of page based.  It turns out the
s390 guys (creators and only users of the XIP framework) prefer the
pfn based scheme.  Now the creators and only users of the XIP
framework are excited about the very changes which allow the framework
to be used by us deviant embedded types.  Everyone is happy!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
