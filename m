Date: Wed, 8 Sep 2004 14:04:31 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: swapping and the value of /proc/sys/vm/swappiness
In-Reply-To: <5860000.1094664673@flay>
Message-ID: <Pine.LNX.4.44.0409081403500.23362-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Ray Bryant <raybry@sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Con Kolivas <kernel@kolivas.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

On Wed, 8 Sep 2004, Martin J. Bligh wrote:

> For HPC, maybe. For a fileserver, it might be far too little. That's the
> trouble ... it's all dependant on the workload. Personally, I'd prefer
> to get rid of manual tweakables (which are a pain in the ass in the field
> anyway), and try to have the kernel react to what the customer is doing.

Agreed.  Many of these things should be self-tunable pretty
easily, too...


-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
