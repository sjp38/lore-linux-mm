Date: Tue, 22 Apr 2003 08:53:50 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: objrmap and vmtruncate
Message-ID: <180520000.1051026829@[10.10.2.4]>
In-Reply-To: <20030422151054.GH8978@holomorphy.com>
References: <20030405143138.27003289.akpm@digeo.com>
 <Pine.LNX.4.44.0304220618190.24063-100000@devserv.devel.redhat.com>
 <20030422123719.GH23320@dualathlon.random>
 <20030422132013.GF8931@holomorphy.com> <171790000.1051022316@[10.10.2.4]>
 <20030422151054.GH8978@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@digeo.com>, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> where the list of address_ranges is sorted by start address. This is
>> intended to make use of the real-world case that many things (like shared
>> libs) map the same exact address ranges over and over again (ie something
>> like 3 ranges, but hundreds or thousands of mappings).
> 
> I'd have to see an empirical demonstration or some previously published
> analysis (or previously published empirical demonstration) to believe
> this does as it should.
> 
> Not to slight the originator, but it is a technique without an a priori
> time (or possibly space either) guarantee, so the trials are warranted.
> 
> I'm overstating the argument because it's hard to make it sound slight;
> it's very plausible something like this could resolve the time issue.

I got sidetracked by the slowdown seeing for massive contention on the
i_shared_sem for even sorting the list. We need to fix that before this is
feasible to do ... (though maybe the list will be sufficiently shorter now
it's less of a problem .... hmmm). Maybe I'll just finish off the code.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
