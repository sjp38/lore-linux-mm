Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7D81C6B00A9
	for <linux-mm@kvack.org>; Mon,  3 Jan 2011 09:26:39 -0500 (EST)
Subject: Re: Should we be using unlikely() around tests of GFP_ZERO?
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <AANLkTik9VodSjNnubf4Psbb9TgOEufw0m2q1_e5+X165@mail.gmail.com>
References: <E1PZXeb-0004AV-2b@tytso-glaptop>
	 <AANLkTi=9ZNk6w8PxvveWHy5+okfTyKUj3L2ywFOuFjoq@mail.gmail.com>
	 <AANLkTinz52Ky5BhU-gHq8vx9=1uoN+iuDn1f0C8fnSjQ@mail.gmail.com>
	 <1294062351.3948.7.camel@gandalf.stny.rr.com>
	 <AANLkTik9VodSjNnubf4Psbb9TgOEufw0m2q1_e5+X165@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Mon, 03 Jan 2011 09:26:36 -0500
Message-ID: <1294064796.3948.12.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Theodore Ts'o <tytso@mit.edu>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, npiggin@kernel.dk
List-ID: <linux-mm.kvack.org>

On Mon, 2011-01-03 at 16:10 +0200, Pekka Enberg wrote:

> >  correct incorrect  %        Function                  File              Line
> >  ------- ---------  -        --------                  ----              ----
> >  6890998  2784830  28        slab_alloc                slub.c            1719
> >
> > That's incorrect 28% of the time.
> 
> Thanks! AFAICT, that number is high enough to justify removing the
> unlikely() annotations, no?

Personally, I think anything that is incorrect more that 5% of the time
should not have any annotation.

My rule is to use the annotation when a branch goes one way 95% or more.
With the exception of times when we want a particular path to be the
faster path, because we know its in a more critical position (as there
are cases in the scheduler and the tracing infrastructure itself).

But here, I think removing it is the right decision.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
