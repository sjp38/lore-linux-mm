Subject: Re: [PATCH 04/10] mm: slub: add knowledge of reserve pages
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1187595513.6114.176.camel@twins>
References: <20070806102922.907530000@chello.nl>
	 <20070806103658.603735000@chello.nl>  <1187595513.6114.176.camel@twins>
Content-Type: text/plain
Date: Mon, 20 Aug 2007 09:43:13 +0200
Message-Id: <1187595793.6114.177.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-08-20 at 09:38 +0200, Peter Zijlstra wrote:
> Ok, so I got rid of the global stuff, this also obsoletes 3/10.
 
2/10 that is

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
