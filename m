Date: Tue, 22 Apr 2003 11:09:53 -0400 (EDT)
From: Ingo Molnar <mingo@redhat.com>
Subject: Re: objrmap and vmtruncate
In-Reply-To: <171070000.1051021955@[10.10.2.4]>
Message-ID: <Pine.LNX.4.44.0304221108090.10400-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@digeo.com>, Andrea Arcangeli <andrea@suse.de>, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 Apr 2003, Martin J. Bligh wrote:

> Oh, BTW. You're assuming no sharing of any pages in the above. Look what
> happens if 1000 processes share the same page ...

i'm not assuming anything - this is the per-process overhead.

processes have well-known RAM overhead associated to the size (and
fragmentation) of their virtual memory space, primarily caused by
pagetables. My suggestion triples this cost [where pte chains double the
costs], but leaves the scaling factor and generic characteristics the
same.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
