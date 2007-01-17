Date: Tue, 16 Jan 2007 20:20:56 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC 5/8] Make writeout during reclaim cpuset aware
Message-Id: <20070116202056.075c4c03.pj@sgi.com>
In-Reply-To: <200701170907.14670.ak@suse.de>
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
	<20070116054809.15358.22246.sendpatchset@schroedinger.engr.sgi.com>
	<200701170907.14670.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: clameter@sgi.com, akpm@osdl.org, menage@google.com, linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, dgc@sgi.com
List-ID: <linux-mm.kvack.org>

Andi wrote:
> Is there a reason this can't be just done by node, ignoring the cpusets?

This suggestion doesn't make a whole lot of sense to me.

We're looking to see if a task has dirtied most of the
pages in the nodes it is allowed to use.  If it has, then
we want to start pushing pages to the disk harder, and
slowing down the tasks writes.

What would it mean to do this per-node?  And why would
that be better?

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
