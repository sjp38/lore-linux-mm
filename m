Date: Tue, 22 Apr 2003 08:10:54 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: objrmap and vmtruncate
Message-ID: <20030422151054.GH8978@holomorphy.com>
References: <20030405143138.27003289.akpm@digeo.com> <Pine.LNX.4.44.0304220618190.24063-100000@devserv.devel.redhat.com> <20030422123719.GH23320@dualathlon.random> <20030422132013.GF8931@holomorphy.com> <171790000.1051022316@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <171790000.1051022316@[10.10.2.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@digeo.com>, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 22, 2003 at 07:38:37AM -0700, Martin J. Bligh wrote:
> where the list of address_ranges is sorted by start address. This is
> intended to make use of the real-world case that many things (like shared
> libs) map the same exact address ranges over and over again (ie something
> like 3 ranges, but hundreds or thousands of mappings).

I'd have to see an empirical demonstration or some previously published
analysis (or previously published empirical demonstration) to believe
this does as it should.

Not to slight the originator, but it is a technique without an a priori
time (or possibly space either) guarantee, so the trials are warranted.

I'm overstating the argument because it's hard to make it sound slight;
it's very plausible something like this could resolve the time issue.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
