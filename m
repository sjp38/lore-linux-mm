Date: Tue, 17 Sep 2002 13:08:51 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: Examining the Performance and Cost of Revesemaps on 2.5.26 Under  Heavy DBWorkload
Message-ID: <50520000.1032293331@flay>
In-Reply-To: <3D878ADD.62BA2DF3@digeo.com>
References: <OF6165D951.694A9B41-ON85256C36.00684F02@pok.ibm.com> <3D878ADD.62BA2DF3@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, Peter Wong <wpeter@us.ibm.com>
Cc: linux-mm@kvack.org, lse-tech@lists.sourceforge.net, riel@nl.linux.org, wli@holomorphy.com, dmccr@us.ibm.com, gh@us.ibm.com, Bill Hartner <bhartner@us.ibm.com>, Troy C Wilson <wilsont@us.ibm.com>
List-ID: <linux-mm.kvack.org>

> That's a ton of memory.  Where do we stand wrt getting these
> applications to use large-tlb pages?

We need standard interfaces (like shmem) to get DB2 to port, and probably 
most other applications. Having magic system calls is all very well in theory,
but not much use in practice. 

And yes, we're still working on it.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
