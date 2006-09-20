Subject: Re: [patch00/05]: Containers(V2)- Introduction
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0609201051550.31636@schroedinger.engr.sgi.com>
References: <1158718568.29000.44.camel@galaxy.corp.google.com>
	 <4510D3F4.1040009@yahoo.com.au> <1158751720.8970.67.camel@twins>
	 <4511626B.9000106@yahoo.com.au> <1158767787.3278.103.camel@taijtu>
	 <451173B5.1000805@yahoo.com.au>
	 <1158774657.8574.65.camel@galaxy.corp.google.com>
	 <Pine.LNX.4.64.0609201051550.31636@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 20 Sep 2006 20:06:26 +0200
Message-Id: <1158775586.28174.27.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Rohit Seth <rohitseth@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, CKRM-Tech <ckrm-tech@lists.sourceforge.net>, devel@openvz.org, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2006-09-20 at 10:52 -0700, Christoph Lameter wrote:
> On Wed, 20 Sep 2006, Rohit Seth wrote:
> 
> > Right now the memory handler in this container subsystem is written in
> > such a way that when existing kernel reclaimer kicks in, it will first
> > operate on those (container with pages over the limit) pages first.  But
> > in general I like the notion of containerizing the whole reclaim code.
> 
> Which comes naturally with cpusets.

How are shared mappings dealt with, are pages charged to the set that
first faults them in?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
