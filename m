Date: Fri, 21 Oct 2005 08:18:34 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 4/4] Swap migration V3: sys_migrate_pages interface
Message-Id: <20051021081834.056a44af.pj@sgi.com>
In-Reply-To: <435896CA.1000101@jp.fujitsu.com>
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com>
	<20051020225955.19761.53060.sendpatchset@schroedinger.engr.sgi.com>
	<4358588D.1080307@jp.fujitsu.com>
	<Pine.LNX.4.61.0510210901380.17098@openx3.frec.bull.fr>
	<435896CA.1000101@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Simon.Derr@bull.net, clameter@sgi.com, akpm@osdl.org, kravetz@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, magnus.damm@gmail.com, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

Kame wrote:
> *new* is already guaranteed to be the subset of current mem_allowed.
> Is this violate the permission ?

The question is not so much whether the current tasks mems_allowed
is violated, but whether the mems_allowed of the cpuset of the
task that owns the pages is violated.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
