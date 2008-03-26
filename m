Date: Wed, 26 Mar 2008 08:59:17 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: larger default page sizes...
In-Reply-To: <18409.56843.909298.717089@cargo.ozlabs.ibm.com>
Message-ID: <alpine.LFD.1.00.0803260854350.2775@woody.linux-foundation.org>
References: <Pine.LNX.4.64.0803211037140.18671@schroedinger.engr.sgi.com> <20080321.145712.198736315.davem@davemloft.net> <Pine.LNX.4.64.0803241121090.3002@schroedinger.engr.sgi.com> <20080324.133722.38645342.davem@davemloft.net> <18408.29107.709577.374424@cargo.ozlabs.ibm.com>
 <87wsnrgg9q.fsf@basil.nowhere.org> <18409.56843.909298.717089@cargo.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Wed, 26 Mar 2008, Paul Mackerras wrote:
> 
> So the improvement in the user time is almost all due to the reduced
> TLB misses (as one would expect).  For the system time, using 64k
> pages in the VM reduces it by about 21%, and using 64k hardware pages
> reduces it by another 30%.  So the reduction in kernel overhead is
> significant but not as large as the impact of reducing TLB misses.

I realize that getting the POWER people to accept that they have been 
total morons when it comes to VM for the last three decades is hard, but 
somebody in the POWER hardware design camp should (a) be told and (b) be 
really ashamed of themselves.

Is this a POWER6 or what? Becasue 21% overhead from TLB handling on 
something like gcc shows that some piece of hardware is absolute crap. 

May I suggest people inside IBM try to fix this some day, and in the 
meantime people outside should probably continue to buy Intel/AMD CPU's 
until the others can get their act together.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
