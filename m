Subject: Re: [patch00/05]: Containers(V2)- Introduction
From: Rohit Seth <rohitseth@google.com>
Reply-To: rohitseth@google.com
In-Reply-To: <1158776824.28174.29.camel@lappy>
References: <1158718568.29000.44.camel@galaxy.corp.google.com>
	 <4510D3F4.1040009@yahoo.com.au> <1158751720.8970.67.camel@twins>
	 <4511626B.9000106@yahoo.com.au> <1158767787.3278.103.camel@taijtu>
	 <451173B5.1000805@yahoo.com.au>
	 <1158774657.8574.65.camel@galaxy.corp.google.com>
	 <Pine.LNX.4.64.0609201051550.31636@schroedinger.engr.sgi.com>
	 <1158775586.28174.27.camel@lappy>
	 <1158776099.8574.89.camel@galaxy.corp.google.com>
	 <1158776824.28174.29.camel@lappy>
Content-Type: text/plain
Date: Wed, 20 Sep 2006 11:38:08 -0700
Message-Id: <1158777488.8574.103.camel@galaxy.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, CKRM-Tech <ckrm-tech@lists.sourceforge.net>, devel@openvz.org, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2006-09-20 at 20:27 +0200, Peter Zijlstra wrote:

> Yes, I read that in your patches, I was wondering how the cpuset
> approach would handle this.
> 
> Neither are really satisfactory for shared mappings.
> 

In which way?  We could have the per container flag indicating whether
to charge this container for shared mapping that it initiates or to the
container where mapping belongs...or is there something different that
you are referring.

-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
