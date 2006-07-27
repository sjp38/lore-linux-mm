Message-ID: <44C8C80F.8010705@mbligh.org>
Date: Thu, 27 Jul 2006 07:05:03 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: use-once cleanup
References: <1153168829.31891.89.camel@lappy>	<44C86FB9.6090709@redhat.com> <20060727011204.87033366.akpm@osdl.org>
In-Reply-To: <20060727011204.87033366.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Rik van Riel <riel@redhat.com>, a.p.zijlstra@chello.nl, linux-mm@kvack.org, torvalds@osdl.org, piggin@cyberone.com.au, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

>>Peter Zijlstra wrote:
>>    
>>
>>>Hi,
>>>
>>>This is yet another implementation of the PG_useonce cleanup spoken of
>>>during the VM summit.
>>>      
>>>
>>After getting bitten by rsync yet again, I guess it's time to insist
>>that this patch gets merged...
>>
>>Andrew, could you merge this?  Pretty please? ;)
>>
>>    
>>
>
>Guys, this is a performance patch, right?
>
>One which has no published performance testing results, right?
>
>It would be somewhat odd to merge it under these circumstances.
>
>And this applies to all of these
>hey-this-is-cool-but-i-didnt-bother-testing-it MM patches which people are
>throwing around.  This stuff is *hard*.  It has a bad tendency to cause
>nasty problems which only become known months after the code is merged.
>
>I shouldn't have to describe all this, but
>
>- Identify the workloads which it's supposed to improve, set up tests,
>  run tests, publish results.
>
>- Identify the workloads which it's expected to damage, set up tests, run
>  tests, publish results.
>
>- Identify workloads which aren't expected to be impacted, make a good
>  effort at demonstrating that they are not impacted.
>
>- Perform stability/stress testing, publish results.
>
>Writing the code is about 5% of the effort for this sort of thing.
>
>Yes, we can toss it in the tree and see what happens.  But it tends to be
>the case that unless someone does targetted testing such as the above,
>regressions simply aren't noticed for long periods of time.  <wonders which
>schmuck gets to do the legwork when people report problems>
>
>Just the (unchangelogged) changes to the when-to-call-mark_page_accessed()
>logic are a big deal.  Probably these should be a separate patch -
>separately changelogged, separately tested, separately justified.
>
>Performance testing is *everything* for this sort of patch and afaict none
>has been done, so it's as if it hadn't been written, no?
>-
>
>  
>
Rik / Peter ... I lost the original mail + patch, but if you put it
up on a URL somewhere, Andy would probably run it through the test
harness for at least some basic perf testing, if you ask him ;-)
Probably against mainline, not -mm, as -mm seems to have other
problems right now.

M.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
