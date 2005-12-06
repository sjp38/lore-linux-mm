Date: Tue, 6 Dec 2005 15:37:02 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC 1/3] Framework for accurate node based statistics
In-Reply-To: <439619F9.4030905@yahoo.com.au>
Message-ID: <Pine.LNX.4.62.0512061536001.20580@schroedinger.engr.sgi.com>
References: <20051206182843.19188.82045.sendpatchset@schroedinger.engr.sgi.com>
 <439619F9.4030905@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Dec 2005, Nick Piggin wrote:

> Why not have per-node * per-cpu counters?

Yes, that is exactly what this patch implements.
 
> Or even use the current per-zone * per-cpu counters, and work out your
> node details from there?

I am not aware of any per-zone per cpu counters.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
