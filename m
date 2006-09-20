Subject: Re: [patch00/05]: Containers(V2)- Introduction
From: Rohit Seth <rohitseth@google.com>
Reply-To: rohitseth@google.com
In-Reply-To: <4510D3F4.1040009@yahoo.com.au>
References: <1158718568.29000.44.camel@galaxy.corp.google.com>
	 <4510D3F4.1040009@yahoo.com.au>
Content-Type: text/plain
Date: Wed, 20 Sep 2006 09:27:46 -0700
Message-Id: <1158769666.8574.10.camel@galaxy.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: CKRM-Tech <ckrm-tech@lists.sourceforge.net>, devel@openvz.org, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2006-09-20 at 15:39 +1000, Nick Piggin wrote:


> Anyway I don't think I have much to say other than: this is almost
> exactly as I had imagined the memory resource tracking should look
> like. Just a small number of hooks and a very simple set of rules for
> tracking allocations. Also, the possibility to track kernel
> allocations as a whole rather than at individual callsites (which
> shouldn't be too difficult to implement).
> 

I've started looking in that direction.  First shot could just be
tracking kernel memory consumption w/o worrying about whether it is slab
or PT etc.  Hopefully next patchset will have that support integrated.

> If anything I would perhaps even argue for further cutting down the
> number of hooks and add them back as they prove to be needed.
> 

I think the current set of changes (and tracking of different
components) is necessary for memory handler to do the right thing.  Plus
it is possible that user land management tools can also make use of this
information.

> I'm not sure about containers & workload management people, but from
> a core mm/ perspective I see no reason why this couldn't get in,
> given review and testing. Great!
> 

That is great to know. Thanks.  Hopefully it is getting enough coverage
to get there.

-rohit


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
