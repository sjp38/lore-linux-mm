Date: Mon, 23 Jul 2007 12:23:33 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] Memoryless nodes:  use "node_memory_map" for cpuset
 mems_allowed validation
Message-Id: <20070723122333.8b21b5fd.pj@sgi.com>
In-Reply-To: <20070723190922.GA6036@us.ibm.com>
References: <20070711182219.234782227@sgi.com>
	<20070711182250.005856256@sgi.com>
	<Pine.LNX.4.64.0707111204470.17503@schroedinger.engr.sgi.com>
	<1184964564.9651.66.camel@localhost>
	<20070723190922.GA6036@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee.Schermerhorn@hp.com, clameter@sgi.com, akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> Or perhaps we should adjust cpusets to make it so that the mems_allowed
> member only includes nodes that are set in node_states[N_MEMORY]?
> 
> What do you think? Paul?

Do you mean the "mems_alloed member" of the task struct ?

That might make sense - changing task->mems_allowed to just include nodes
with memory.

Someone would have to audit the entire kernel for uses of task->mems_allowed,
to see if all uses would be ok with this change.

I'm on vacation this week and next, so won't be doing that work right now.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
