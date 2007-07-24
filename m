Date: Mon, 23 Jul 2007 23:10:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: -mm merge plans for 2.6.23
Message-Id: <20070723231015.34b22dcb.akpm@linux-foundation.org>
In-Reply-To: <2c0942db0707232301o5ab428bdrd1bc831cacf806c@mail.gmail.com>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	<200707102015.44004.kernel@kolivas.org>
	<9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	<46A57068.3070701@yahoo.com.au>
	<2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	<20070723221846.d2744f42.akpm@linux-foundation.org>
	<2c0942db0707232301o5ab428bdrd1bc831cacf806c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Lee <ray-lk@madrabbit.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 23 Jul 2007 23:01:41 -0700 "Ray Lee" <ray-lk@madrabbit.org> wrote:

> So, what do I measure to make this an objective problem report?

Ideal would be to find a reproducible-by-others testcase which does what you
believe to be the wrong thing.

> And if
> I do that (and it shows a positive result), will that be good enough
> to argue for inclusion?

That depends upon whether there are more suitable ways of fixing "the
wrong thing".

There may not be - it could well be that present behaviour
is correct for the testcase, but it leaves the system in the wrong
state for your large workload shift.  In that case, prefetching (ie:
restoring system state approximately to that which prevailed prior to
"testcase") might well be a suitable fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
