Subject: Re: [PATCH] mm: tracking shared dirty pages -v10
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0606230955230.6265@schroedinger.engr.sgi.com>
References: <20060619175243.24655.76005.sendpatchset@lappy>
	 <20060619175253.24655.96323.sendpatchset@lappy>
	 <Pine.LNX.4.64.0606222126310.26805@blonde.wat.veritas.com>
	 <1151019590.15744.144.camel@lappy>
	 <Pine.LNX.4.64.0606222305210.6483@g5.osdl.org>
	 <Pine.LNX.4.64.0606230759480.19782@blonde.wat.veritas.com>
	 <Pine.LNX.4.64.0606230955230.6265@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 23 Jun 2006 19:22:18 +0200
Message-Id: <1151083338.30819.28.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-06-23 at 10:00 -0700, Christoph Lameter wrote:

> Also Peter has made the tracking configurable. So there is a way
> to switch it off if it is harmful for some situations.

Oh?

> You mean anonymous pages? Anonymous pages are always dirty unless
> you consider swap and we currently do not take account of dirty anonymous 
> pages. With swap we already have performance problems and maybe there are
> additional issues to fix in that area. But these are secondary.

I intent to make swap over NFS work next.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
