Message-ID: <45118270.60901@yahoo.com.au>
Date: Thu, 21 Sep 2006 04:03:28 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch00/05]: Containers(V2)- Introduction
References: <1158718568.29000.44.camel@galaxy.corp.google.com> <4510D3F4.1040009@yahoo.com.au> <Pine.LNX.4.64.0609200925280.30572@schroedinger.engr.sgi.com> <451172AB.2070103@yahoo.com.au> <Pine.LNX.4.64.0609201006420.30793@schroedinger.engr.sgi.com> <45117830.3080909@yahoo.com.au> <Pine.LNX.4.64.0609201024310.31178@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609201024310.31178@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: rohitseth@google.com, pj@sgi.com, CKRM-Tech <ckrm-tech@lists.sourceforge.net>, devel@openvz.org, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Thu, 21 Sep 2006, Nick Piggin wrote:
> 
> 
>>Patch 2/5 in this series provides hooks, and they are pretty unintrusive.
> 
> 
> Ok. We shadow existing vm counters add stuff to the adress_space 
> structure. The task add / remove is duplicating what some of the cpuset 
> hooks do. That clearly shows that we are just duplicating functionality.

I don't think so. To start with, the point about containers is they are
not per address_space.

But secondly, these are hooks from the container subsystem into the mm
subsystem. As such, they might do something a bit more or different
than simple statistics, and we don't want to teach the core mm/ about
what that might be. You also want to be able to configure them out
entirely.

I think it is fine to add some new hooks in fundamental (ie mm agnostic)
points. Without getting to the fine details about exactly how the hooks
are implemented, or what information needs to be tracked, I think we can
say that they are not much burden for mm/ to bear (if they turn out to
be usable).

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
