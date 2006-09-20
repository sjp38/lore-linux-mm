Date: Wed, 20 Sep 2006 12:48:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch00/05]: Containers(V2)- Introduction
In-Reply-To: <1158775586.28174.27.camel@lappy>
Message-ID: <Pine.LNX.4.64.0609201247300.32409@schroedinger.engr.sgi.com>
References: <1158718568.29000.44.camel@galaxy.corp.google.com>
 <4510D3F4.1040009@yahoo.com.au> <1158751720.8970.67.camel@twins>
 <4511626B.9000106@yahoo.com.au> <1158767787.3278.103.camel@taijtu>
 <451173B5.1000805@yahoo.com.au>  <1158774657.8574.65.camel@galaxy.corp.google.com>
  <Pine.LNX.4.64.0609201051550.31636@schroedinger.engr.sgi.com>
 <1158775586.28174.27.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rohit Seth <rohitseth@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, CKRM-Tech <ckrm-tech@lists.sourceforge.net>, devel@openvz.org, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Sep 2006, Peter Zijlstra wrote:

> > Which comes naturally with cpusets.
> 
> How are shared mappings dealt with, are pages charged to the set that
> first faults them in?

They are charged to the node from which they were allocated. If the 
process is restricted to the node (container) then all pages allocated 
are are charged to the container regardless if they are shared or not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
