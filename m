Date: Sun, 29 Jul 2007 05:35:16 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 00/14] NUMA: Memoryless node support V4
Message-Id: <20070729053516.5d85738a.pj@sgi.com>
In-Reply-To: <20070727194316.18614.36380.sendpatchset@localhost>
References: <20070727194316.18614.36380.sendpatchset@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, ak@suse.de, nacc@us.ibm.com, kxr@sgi.com, clameter@sgi.com, mel@skynet.ie, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Lee,

What is the motivation for memoryless nodes?  I'm not sure what I
mean by that question -- perhaps the answer involves describing a
piece of hardware, perhaps a somewhat hypothetical piece of hardware
if the real hardware is proprietary.  But usually adding new mechanisms
to the kernel should involve explaining why it is needed.

In this case, it might further involve explaining why we need memoryless
nodes, as opposed to say a hack for the above (hypothetical?) hardware
in question that pretends that any CPUs on such memoryless nodes are on
the nearest memory equipped node -- and then entirely drops the idea of
memoryless nodes.  Most likely you have good reason not to go this way.
Good chance even you've already explained this, and I missed it.

===

I have user level code that scans the 'cpu%d' entries below the
/sys/devices/system/node%d directories, and then inverts the resulting
<node, cpu> map, in order to provide, for any given cpu the nearest
node.  This code is a simple form of node and cpu topology for user
code that wants to setup cpusets with cpus and nodes 'near' each other.

Could you post the results, from such a (possibly hypothetical) machine,
of the following two commands:

  find /sys/devices/system/node* -name cpu[0-9]\*
  ls /sys/devices/system/cpu

And if the 'ls' shows cpus that the 'find' doesn't show, then can you
recommend how user code should be written that would return, for any
specified cpu (even one on a memoryless node) the number of the
'nearest' node that does have memory (for some plausible definition,
your choice pretty much, of 'nearest')?

Granted, this is not a pressing issue ... not much chance that my user
code will be running on your (hypothetical?) hardware anytime soon,
unless there is some deal in the works I don't know about for hp to
buy sgi ;).

In short, how should user code find 'nearby' memory nodes for cpus that
are on memoryless nodes?

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
