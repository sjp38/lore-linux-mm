Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C1C2C6B01E3
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 12:06:12 -0400 (EDT)
Message-ID: <4BC1F31E.2050009@redhat.com>
Date: Sun, 11 Apr 2010 19:04:46 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: hugepages will matter more in the future
References: <20100410194751.GA23751@elte.hu> <4BC0DE84.3090305@redhat.com> <4BC0E2C4.8090101@redhat.com> <q2s28f2fcbc1004101349ye3e44c9cl4f0c3605c8b3ffd3@mail.gmail.com> <4BC0E556.30304@redhat.com> <4BC19663.8080001@redhat.com> <v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com> <4BC19916.20100@redhat.com> <20100411110015.GA10149@elte.hu> <4BC1B034.4050302@redhat.com> <20100411115229.GB10952@elte.hu> <alpine.LFD.2.00.1004110814080.3576@i5.linux-foundation.org> <4BC1EE13.7080702@redhat.com> <alpine.LFD.2.00.1004110844420.3576@i5.linux-foundation.org>
In-Reply-To: <alpine.LFD.2.00.1004110844420.3576@i5.linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Jason Garrett-Glaser <darkshikari@gmail.com>, Mike Galbraith <efault@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>

On 04/11/2010 06:52 PM, Linus Torvalds wrote:
>
> On Sun, 11 Apr 2010, Avi Kivity wrote:
>    
>> And yet Oracle and java have options to use large pages, and we know google
>> and HPC like 'em.  Maybe they just haven't noticed the fundamental brokenness
>> yet.
>>      
> The thing is, what you are advocating is what traditional UNIX did.
> Prioritizing the special cases rather than the generic workloads.
>
> And I'm telling you, it's wrong. Traditional Unix is dead, and it's dead
> exactly _because_ it prioritized those kinds of loads.
>    

This is not a specialized workload.  Plenty of sites are running java, 
plenty of sites are running Oracle (though that won't benefit from 
anonymous hugepages), and plenty of sites are running virtualization.  
Not everyone does two kernel builds before breakfast.

> I'm perfectly happy to take specialized workloads into account, but it
> needs to help the _normal_ case too. Somebody mentioned 4k CPU support as
> an example, and that's a good example. The only reason we support 4k CPU's
> is that the code was made clean enough to work with them and actually
> help clean up the SMP code in general.
>
> I've also seen Andrea talk about how it's all rock solid. We _know_ that
> is wrong, because the anon_vma bug is not solved. That bug apparently
> happens under low-memory situations, so clearly nobody has really stressed
> the low-memory case.
>    

Well, nothing is rock solid until it's had a few months in the hands of 
users.

> So here's the deal: make the code cleaner, and it's fine. And stop trying
> to sell it with _crap_.
>    

That's perfectly reasonable.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
