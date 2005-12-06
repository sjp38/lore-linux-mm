Date: Tue, 6 Dec 2005 15:40:41 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC 1/3] Framework for accurate node based statistics
In-Reply-To: <Pine.LNX.4.62.0512061536001.20580@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.62.0512061539280.20618@schroedinger.engr.sgi.com>
References: <20051206182843.19188.82045.sendpatchset@schroedinger.engr.sgi.com>
 <439619F9.4030905@yahoo.com.au> <Pine.LNX.4.62.0512061536001.20580@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Tue, 6 Dec 2005, Christoph Lameter wrote:

> I am not aware of any per-zone per cpu counters.

Argh. Wrong. Yes there are counters in the per cpu structures for each 
zone. The pointers here could be folded into that and then would give us 
zone based statistics which may be better than per node statistics for 
decision making about memory in a zone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
