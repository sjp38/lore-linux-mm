Date: Fri, 27 Dec 2002 19:19:44 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: shared pagetable benchmarking
Message-ID: <5540000.1041045583@titus>
In-Reply-To: <3E0D0D99.5EB318E5@digeo.com>
References: <Pine.LNX.4.44.0212271244390.771-100000@home.transmeta.com>
 <311610000.1041036301@flay> <3E0D0D99.5EB318E5@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Dave McCracken <dmccr@us.ibm.com>, Daniel Phillips <phillips@arcor.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> To what extent is that a "real" workload?

It was meant to be a simulation of a real customer enviroment,
I don't think it's unrealistic (they were actually trying to push it
to at least twice that).

> What other applications are affected, and to what extent?

Anything that does heavy sharing. Databases and Java heaps spring
to mind.

> Why are hugepages not a sufficient solution?

They may be for some workloads, but it's not as generalised. For
instance, one other thing that's being muttered about a lot is very
large heaps for Java workloads, and they want those swap backed.
Large pages also requires application modification and machine setup
for static pool size reservations in the current implementation.

> Is this problem sufficiently common to warrant the inclusion of
> pagetable sharing in the main kernel, as opposed to a specialised
> Oracle/DB2 derivative?

If we can get it not to degrade anything else (eg fork on small tasks),
I think it's worthwhile. I *think* we're there now, though a few more
perf checks are probably needed.

>> I think the long-term fix for the rmap performance hit is object-based
>> RMAP (doing the reverse mappings shared on a per-area basis) which we've
>> talked about, but not for 2.6 ... it may not turn out to be that hard
>> though ... K42 did it before.
>
> I think we can do a few things still in the 2.6 context.  The fact that
> my "apply seventy patches with patch-scripts" test takes 350,000
> pagefaults in 13 seconds makes one go "hmm".

Fixing that would be a worthy goal, IMHO.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
