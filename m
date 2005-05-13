Date: Fri, 13 May 2005 09:20:34 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: NUMA aware slab allocator V2
In-Reply-To: <1115992613.7129.10.camel@localhost>
Message-ID: <Pine.LNX.4.58.0505130915400.4500@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>
 <20050512000444.641f44a9.akpm@osdl.org>  <Pine.LNX.4.58.0505121252390.32276@schroedinger.engr.sgi.com>
  <20050513000648.7d341710.akpm@osdl.org>  <Pine.LNX.4.58.0505130411300.4500@schroedinger.engr.sgi.com>
  <20050513043311.7961e694.akpm@osdl.org>  <Pine.LNX.4.58.0505130436380.4500@schroedinger.engr.sgi.com>
 <1115992613.7129.10.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, shai@scalex86.org, steiner@sgi.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Fri, 13 May 2005, Dave Hansen wrote:

> I think I found the problem.  Could you try the attached patch?

Ok. That is a part of the problem. The other issue that I saw while
testing is that the new slab allocator fails on 64 bit non NUMA platforms
because the bootstrap does not work right. The size of struct kmem_list3
may become > 64 bytes (with preempt etc on which increases the size of the
spinlock_t) which requires an additional slab to be handled in a special
way during bootstrap. I hope I will have an updated patch soon.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
