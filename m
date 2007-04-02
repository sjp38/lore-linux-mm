Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l32KDM29022177
	for <linux-mm@kvack.org>; Mon, 2 Apr 2007 16:13:22 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l32KDMZM189244
	for <linux-mm@kvack.org>; Mon, 2 Apr 2007 14:13:22 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l32KDLTj005059
	for <linux-mm@kvack.org>; Mon, 2 Apr 2007 14:13:21 -0600
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
From: Dave Hansen <hansendc@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
	 <20070401071029.23757.78021.sendpatchset@schroedinger.engr.sgi.com>
	 <200704011246.52238.ak@suse.de>
	 <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 02 Apr 2007 13:13:17 -0700
Message-Id: <1175544797.22373.62.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-04-02 at 08:37 -0700, Christoph Lameter wrote:
> You want a benchmark to prove that the removal of memory references and 
> code improves performance? 

Yes, please. ;)

I completely agree, it looks like it should be faster.  The code
certainly has potential benefits.  But, to add this neato, apparently
more performant feature, we unfortunately have to add code.  Adding the
code has a cost: code maintenance.  This isn't a runtime cost, but it is
a real, honest to goodness tradeoff.

So, let's get some kind of concrete idea what the tradeoffs are.  Is it,
400 lines of code gets us a 10% performance boost across the board, or
that 400,000 lines gets us 0.1% on one specialized benchmark?

BTW, I like the patches.  Very nice and clean.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
