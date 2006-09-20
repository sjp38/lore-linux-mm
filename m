Message-ID: <451172AB.2070103@yahoo.com.au>
Date: Thu, 21 Sep 2006 02:56:11 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch00/05]: Containers(V2)- Introduction
References: <1158718568.29000.44.camel@galaxy.corp.google.com> <4510D3F4.1040009@yahoo.com.au> <Pine.LNX.4.64.0609200925280.30572@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609200925280.30572@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: rohitseth@google.com, CKRM-Tech <ckrm-tech@lists.sourceforge.net>, devel@openvz.org, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 20 Sep 2006, Nick Piggin wrote:
> 
> 
>>I'm not sure about containers & workload management people, but from
>>a core mm/ perspective I see no reason why this couldn't get in,
>>given review and testing. Great!
> 
> 
> Nack. We already have the ability to manage workloads. We may want to 
> extend the existing functionality but this is duplicating what is already 
> available through cpusets.

If it wasn't clear was talking specifically about the hooks for page
tracking rather than the whole patchset. If anybody wants such page
tracking infrastructure in the kernel, then this (as opposed to the
huge beancounters stuff) is what it should look like.

But as I said above, I don't know what the containers and workload
management people want exactly... The recent discussions about using
nodes and cpusets for memory workload management does seem like a
promising idea, and if it would avoid the need for this kind of
per-page tracking entirely, then that would probably be even better.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
