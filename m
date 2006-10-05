Date: Wed, 4 Oct 2006 21:50:19 -0700 (PDT)
From: David Rientjes <rientjes@cs.washington.edu>
Subject: Re: [RFC] another way to speed up fake numa node page_alloc
In-Reply-To: <20061004210711.aefaea6c.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64N.0610042138580.5625@attu4.cs.washington.edu>
References: <20060925091452.14277.9236.sendpatchset@v0> <20061001231811.26f91c47.pj@sgi.com>
 <Pine.LNX.4.64N.0610012330110.10476@attu4.cs.washington.edu>
 <20061001234858.fe91109e.pj@sgi.com> <Pine.LNX.4.64N.0610020001240.7510@attu3.cs.washington.edu>
 <20061002014121.28b759da.pj@sgi.com> <20061003111517.a5cc30ea.pj@sgi.com>
 <Pine.LNX.4.64N.0610031231270.4919@attu3.cs.washington.edu>
 <20061004084552.a07025d7.pj@sgi.com> <Pine.LNX.4.64N.0610041456480.19080@attu2.cs.washington.edu>
 <20061004192714.20412e08.pj@sgi.com> <Pine.LNX.4.64N.0610041931170.32103@attu2.cs.washington.edu>
 <20061004195313.892838e4.pj@sgi.com> <Pine.LNX.4.64N.0610041954470.642@attu2.cs.washington.edu>
 <20061004202656.18830f76.pj@sgi.com> <Pine.LNX.4.64N.0610042036230.27222@attu3.cs.washington.edu>
 <20061004210711.aefaea6c.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, 4 Oct 2006, Andrew Morton wrote:

> We do that sort of thing all the time ;)
> 
> It's sometimes OK to rely on common sense and not require benchmark results
> or in-field observations for everything.
> 
> Or one can concoct artificial microbenchmarks, measure the impact and then
> use plain old brainpower to decide whether anyone is ever likely to want to
> do anything in real life which is approximately modelled by that benchmark.
> 
> The latter is the case here and I'd say the answer is "yes".  People might
> be impacted by this in real life.
> 

Ah, it's ok to ask for benchmarks in the fake case which _nobody_ uses but 
benchmarks in the real case which a lot of people use is unnecessary.

The funny thing is that it's not going to make the real case more 
efficient at all if you follow real-world examples.  Usually memory is 
going to be found in the first zone anyway and when it's not it's going to 
be found next.  This is, after all, why the zone ordering has worked and 
nobody has had a problem with it.  (Not to mention you're clearing the 
nodemask every second anyway.)  I was hoping this would be evident in the 
real case if you'd just run the code on your 1024 node setup.  I guess 
that will be realized later.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
