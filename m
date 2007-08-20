Message-ID: <46C92AF4.20607@google.com>
Date: Sun, 19 Aug 2007 22:47:32 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: cpusets vs. mempolicy and how to get interleaving
References: <46C63BDE.20602@google.com>	<46C63D5D.3020107@google.com>	<alpine.DEB.0.99.0708190304510.7613@chino.kir.corp.google.com>	<46C8E604.8040101@google.com> <20070819193431.dce5d4cf.pj@sgi.com>
In-Reply-To: <20070819193431.dce5d4cf.pj@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: rientjes@google.com, clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
> Ethan wrote:
>> 	And what happens when the weight then goes back up? e.g. at first the 
>> mems_allowed specifies nodes 0 and 1, and the user sets a 
>> MPOL_INTERLEAVE policy across nodes 0 and 1. At some point the "cpuset 
>> manager" shrinks the number of nodes to just node 0, then later it adds 
>> back node 1. What nodes are in my MPOL_INTERLEAVE policy?
>>
>> 	As I read the code, I'll only have one node in the mempolicy. If that's 
>> true, this doesn't do what I want.
> 
> I read the code the same way.
> 
> Sounds to me like you want a new and different MPOL_* mempolicy, that
> interleaves over whatever nodes are available (allowed) to the task.
> 
> The existing MPOL_INTERLEAVE mempolicy interleaves over some specified
> nodemask, so we do the best we can to remap that set when it changes.
> 
> You want a mempolicy that interleaves over all available nodes, not over
> some specified subset of them.

	OK, then I'll proceed with a new MPOL. Do you believe that this will be 
of general interest? i.e. worth placing in linux-mm?

	BTW, a slightly different MPOL_INTERLEAVE implementation would help, 
wherein we save the nodemask originally specified by the user and do the 
remap from the original nodemask rather than the current nodemask. This 
would also let the user specify an all-ones nodemask which would then be 
remapped onto mems_allowed. But I'm guessing that these changes would be 
impossible due to breaking compatibility?
	-- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
