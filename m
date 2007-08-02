Date: Thu, 2 Aug 2007 16:17:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Fix two potential mem leaks in MPT Fusion
 (mpt_attach())
Message-Id: <20070802161730.1d5bb55b.akpm@linux-foundation.org>
In-Reply-To: <9a8748490708021610k31a86c17y58fb631a36dfdb6a@mail.gmail.com>
References: <200708020155.33690.jesper.juhl@gmail.com>
	<20070801172653.1fd44e99.akpm@linux-foundation.org>
	<9a8748490708020120w4bbfe6d1n6f6986aec507316@mail.gmail.com>
	<200708030053.45297.jesper.juhl@gmail.com>
	<20070802160406.5c5b5ff6.akpm@linux-foundation.org>
	<9a8748490708021610k31a86c17y58fb631a36dfdb6a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jesper Juhl <jesper.juhl@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, James Bottomley <James.Bottomley@steeleye.com>, Christoph Lameter <clameter@sgi.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Fri, 3 Aug 2007 01:10:02 +0200
"Jesper Juhl" <jesper.juhl@gmail.com> wrote:

> > > So, where do we go from here?
> >
> > Where I said ;) Add a new __GFP_ flag which suppresses the warning, add
> > that flag to known-to-be-OK callsites, such as mempool_alloc().
> >
> Ok, I'll try to play around with this some more, try to filter out
> false positives and see what I'm left with (if anything - I'm pretty
> limited hardware-wise, so I can only test a small subset of drivers,
> archs etc) - I'll keep you informed, but expect a few days to pass
> before I have any news...

Make it a once-off thing for now, so the warning will disable itself after
it has triggered once.  That will prevent the debug feature from making
anyone's kernel unusable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
