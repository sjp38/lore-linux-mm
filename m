Date: Fri, 21 Oct 2005 08:22:45 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 4/4] Swap migration V3: sys_migrate_pages interface
Message-Id: <20051021082245.5c540dca.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.61.0510210927140.17098@openx3.frec.bull.fr>
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com>
	<20051020225955.19761.53060.sendpatchset@schroedinger.engr.sgi.com>
	<4358588D.1080307@jp.fujitsu.com>
	<Pine.LNX.4.61.0510210901380.17098@openx3.frec.bull.fr>
	<435896CA.1000101@jp.fujitsu.com>
	<Pine.LNX.4.61.0510210927140.17098@openx3.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Simon Derr <Simon.Derr@bull.net>
Cc: kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com, akpm@osdl.org, kravetz@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, magnus.damm@gmail.com, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

Simon wrote:
> Maybe sometimes the user would be interested in migrating all the 
> existing pages of a process, but not change the policy for the future ?

So long as the user has some reasonable right to change the affected
tasks memory layout, and so long as they are moving memory within the
cpuset constraints (if any) of the affected task, or as close to that
as practical (such as with ECC soft error avoidance), then yes, it would
seem that this sys_migrate_pages() lets existing pages be moved without
changing the cpuset policy for the future.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
