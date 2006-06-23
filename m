Date: Thu, 22 Jun 2006 23:08:43 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH] mm: tracking shared dirty pages -v10
In-Reply-To: <1151019590.15744.144.camel@lappy>
Message-ID: <Pine.LNX.4.64.0606222305210.6483@g5.osdl.org>
References: <20060619175243.24655.76005.sendpatchset@lappy>
 <20060619175253.24655.96323.sendpatchset@lappy>
 <Pine.LNX.4.64.0606222126310.26805@blonde.wat.veritas.com>
 <1151019590.15744.144.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>


On Fri, 23 Jun 2006, Peter Zijlstra wrote:
>
> Preview of the goodness,
> 
> I'll repost the whole thing tomorrow after I've updated the other
> patches, esp. the msync one. I seem to be too tired to make any sense
> out of that atm.

Do people agree about this thing? If we want it in 2.6.18, we should merge 
this soon. I'd prefer to not leave something like this to be a last-minute 
thing before the merge window closes, and I get the feeling that we're 
getting to where this should just go in sooner rather than later.

Comments? Hugh, does the last version address all your concerns?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
