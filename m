Date: Fri, 21 Oct 2005 10:03:57 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 4/4] Swap migration V3: sys_migrate_pages interface
Message-Id: <20051021100357.3397269e.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.62.0510210926120.23328@schroedinger.engr.sgi.com>
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com>
	<20051020225955.19761.53060.sendpatchset@schroedinger.engr.sgi.com>
	<4358588D.1080307@jp.fujitsu.com>
	<Pine.LNX.4.61.0510210901380.17098@openx3.frec.bull.fr>
	<435896CA.1000101@jp.fujitsu.com>
	<Pine.LNX.4.62.0510210926120.23328@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: kamezawa.hiroyu@jp.fujitsu.com, Simon.Derr@bull.net, akpm@osdl.org, kravetz@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, magnus.damm@gmail.com, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

Christoph wrote:
> Could the cpuset_mems_allowed(task) function update the mems_allowed if 
> needed?

I'm not sure what you're thinking here.  Instead of my asking a dozen
stupid questions, I guess I should just ask you to explain what you
have in mind more.

The function call you show above has no 'mask' argument, so I don't
know what you intend to update mems_allowed to.  Currently, a task
mems_allowed is only updated in task context, from its cpusets
mems_allowed. The task mems_allowed is updated automatically coming
into the page allocation code, if the tasks mems_generation doesn't
match its cpusets mems_generation.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
