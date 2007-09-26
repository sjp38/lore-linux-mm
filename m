Date: Tue, 25 Sep 2007 20:57:46 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [patch -mm 7/5] oom: filter tasklist dump by mem_cgroup
Message-Id: <20070925205746.dd74a887.pj@sgi.com>
In-Reply-To: <6599ad830709251822q371c4a62rfdf8911720edb86c@mail.gmail.com>
References: <alpine.DEB.0.9999.0709250035570.11015@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709250037030.11015@chino.kir.corp.google.com>
	<6599ad830709251100n352028beraddaf2ac33ea8f6c@mail.gmail.com>
	<20070925181442.aeb7b205.pj@sgi.com>
	<6599ad830709251822q371c4a62rfdf8911720edb86c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: rientjes@google.com, akpm@linux-foundation.org, clameter@sgi.com, balbir@linux.vnet.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Paul M wrote:
> You could print any tasks that share memory nodes (in their cpuset)
> with the OOMing task.

Huh?  I'm mystified.  Why would printing tasks help avoid choosing
the wrong task to oom kill?

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
