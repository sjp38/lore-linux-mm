Date: Fri, 27 Dec 2002 16:45:01 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: shared pagetable benchmarking
Message-ID: <311610000.1041036301@flay>
In-Reply-To: <Pine.LNX.4.44.0212271244390.771-100000@home.transmeta.com>
References: <Pine.LNX.4.44.0212271244390.771-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, Dave McCracken <dmccr@us.ibm.com>
Cc: Daniel Phillips <phillips@arcor.de>, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I don't consider it important enough to qualify unless there are some real 
> loads where it really matters. I can well imagine that such loads exist 
> (where low-memory usage by page tables is a real problem), but I'd like to 
> have that confirmed as a bug-report and that the sharing really does fix 
> it.

We had over 10Gb of PTEs running Oracle Apps (on 2.4 without RMAP) - 
RMAP would add another 5Gb or so to that (2Gb shared memory segment 
across many processes). But you can stick PTEs in highmem, whereas 
it's not easy to do that with pte_chains ... sticking 5Gb of overhead 
into ZONE_NORMAL is tricky ;-) The really nice thing about shared 
pagetables as a solution is that it's totally transparent, and requires 
no app modifications. Obviously degrading fork for small tasks is
unacceptable, but Dave seems to have fixed that issue now.

I think the long-term fix for the rmap performance hit is object-based 
RMAP (doing the reverse mappings shared on a per-area basis) which we've 
talked about, but not for 2.6 ... it may not turn out to be that hard 
though ... K42 did it before.

M.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
