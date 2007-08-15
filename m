Date: Wed, 15 Aug 2007 16:34:22 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
Message-ID: <20070815143422.GA653@one.firstfloor.org>
References: <20070814142103.204771292@sgi.com> <20070815122253.GA15268@wotan.suse.de> <1187183526.6114.45.camel@twins> <p731we43muw.fsf@bingen.suse.de> <1187186120.6114.56.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1187186120.6114.56.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

> That is his second patch-set, and I do worry about the irq latency that
> that will introduce. It very much has the potential to ruin everything
> that cares about interactiveness or latency.

I proposed a way to avoid increasing interrupt latency
in a simple way.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
