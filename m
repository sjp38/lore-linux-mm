Date: Wed, 08 Sep 2004 10:31:13 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: swapping and the value of /proc/sys/vm/swappiness
Message-ID: <5860000.1094664673@flay>
In-Reply-To: <413F1518.7050608@sgi.com>
References: <413CB661.6030303@sgi.com> <cone.1094512172.450816.6110.502@pc.kolivas.org> <20040906162740.54a5d6c9.akpm@osdl.org> <cone.1094513660.210107.6110.502@pc.kolivas.org> <20040907000304.GA8083@logos.cnet> <20040907212051.GC3492@logos.cnet> <413F1518.7050608@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Con Kolivas <kernel@kolivas.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

> It seems to me that the 5% number in there is more or less arbitrary. 
> If we are on a big memory Altix (4 TB), 5% of memory would be 200 GB. 
> That is a lot of page cache.

For HPC, maybe. For a fileserver, it might be far too little. That's the
trouble ... it's all dependant on the workload. Personally, I'd prefer
to get rid of manual tweakables (which are a pain in the ass in the field
anyway), and try to have the kernel react to what the customer is doing.
I guess we can leave them there for overrides, but a self-tunable default
would be most desirable.

For instance, would be nice if we started doing writeback to the spindles
that weren't busy much earlier than if the disks were thrashing.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
