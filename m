Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id SAA11560
	for <linux-mm@kvack.org>; Fri, 27 Dec 2002 18:34:02 -0800 (PST)
Message-ID: <3E0D0D99.5EB318E5@digeo.com>
Date: Fri, 27 Dec 2002 18:34:01 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: shared pagetable benchmarking
References: <Pine.LNX.4.44.0212271244390.771-100000@home.transmeta.com> <311610000.1041036301@flay>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Dave McCracken <dmccr@us.ibm.com>, Daniel Phillips <phillips@arcor.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
> > I don't consider it important enough to qualify unless there are some real
> > loads where it really matters. I can well imagine that such loads exist
> > (where low-memory usage by page tables is a real problem), but I'd like to
> > have that confirmed as a bug-report and that the sharing really does fix
> > it.
> 
> We had over 10Gb of PTEs running Oracle Apps (on 2.4 without RMAP) -
> RMAP would add another 5Gb or so to that (2Gb shared memory segment
> across many processes). But you can stick PTEs in highmem, whereas
> it's not easy to do that with pte_chains ... sticking 5Gb of overhead
> into ZONE_NORMAL is tricky ;-) The really nice thing about shared
> pagetables as a solution is that it's totally transparent, and requires
> no app modifications. Obviously degrading fork for small tasks is
> unacceptable, but Dave seems to have fixed that issue now.

To what extent is that a "real" workload?

What other applications are affected, and to what extent?

Why are hugepages not a sufficient solution?

Is this problem sufficiently common to warrant the inclusion of
pagetable sharing in the main kernel, as opposed to a specialised
Oracle/DB2 derivative?

> I think the long-term fix for the rmap performance hit is object-based
> RMAP (doing the reverse mappings shared on a per-area basis) which we've
> talked about, but not for 2.6 ... it may not turn out to be that hard
> though ... K42 did it before.

I think we can do a few things still in the 2.6 context.  The fact that
my "apply seventy patches with patch-scripts" test takes 350,000 pagefaults
in 13 seconds makes one go "hmm".
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
