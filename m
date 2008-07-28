Subject: Re: [PATCH 12/30] mm: memory reserve management
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1217241541.6331.42.camel@twins>
References: <20080724140042.408642539@chello.nl>
	 <20080724141530.127530749@chello.nl>
	 <1217239564.7813.36.camel@penberg-laptop>  <1217240224.6331.32.camel@twins>
	 <1217240994.7813.53.camel@penberg-laptop>  <1217241541.6331.42.camel@twins>
Date: Mon, 28 Jul 2008 13:41:24 +0300
Message-Id: <1217241684.7813.59.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Neil Brown <neilb@suse.de>, mpm@selenic.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi Peter,

On Mon, 2008-07-28 at 12:39 +0200, Peter Zijlstra wrote:
> Also, you might have noticed, I still need to do everything SLOB. The
> last time I rewrote all this code I was still hoping Linux would 'soon'
> have a single slab allocator, but evidently we're still going with 3 for
> now.. :-/
> 
> So I guess I can no longer hide behind that and will have to bite the
> bullet and write the SLOB bits..

Oh, I don't expect SLOB to go away anytime soon. We are still trying to
get rid of SLAB, though, but there are some TPC regressions that we
don't have a reproducible test case for so that effort has stalled a
bit.

		Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
