Date: Thu, 16 Aug 2007 13:27:24 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
In-Reply-To: <20070816032921.GA32197@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0708161324390.17777@schroedinger.engr.sgi.com>
References: <20070814142103.204771292@sgi.com> <20070815122253.GA15268@wotan.suse.de>
 <1187183526.6114.45.camel@twins> <20070816032921.GA32197@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Aug 2007, Nick Piggin wrote:

> > Honestly, I don't. They very much do not solve the problem, they just
> > displace it.
> 
> Well perhaps it doesn't work for networked swap, because dirty accounting
> doesn't work the same way with anonymous memory... but for _filesystems_,
> right?

Regular reclaim also cannot immediately write out pages. Writes are 
usually deferred. If you have too many anonymous pages in regular reclaim 
then you can have the same issues.

The difference is that recursive reclaim does not trigger writeout at 
the moment but we could address that by having a pageout list that then 
starts writes from another context. Then both reclaims would be able to 
trigger writeout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
