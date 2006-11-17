Subject: Re: [ckrm-tech] [RFC][PATCH 5/8] RSS controller task migration support
Message-Id: <20061117132533.A5FCF1B6A2@openx4.frec.bull.fr>
Date: Fri, 17 Nov 2006 14:25:33 +0100 (CET)
From: Patrick.Le-Dot@bull.net (Patrick.Le-Dot)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@in.ibm.com
Cc: ckrm-tech@lists.sourceforge.net, dev@openvz.org, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rohitseth@google.com
List-ID: <linux-mm.kvack.org>

> ...
> For implementing guarantees, we can use limits. Please see
> http://wiki.openvz.org/Containers/Guarantees_for_resources.

Nack.

This seems to be correct for resources like cpu, disk or network
bandwidth but not for the memory just because nobody in this wiki
speaks about the kswapd and page reclaim (but it's true that a such
demon does not exist for cpu, disk or... then the problem is more
simple).

For a customer the main reason to use guarantee is to be sure that
some pages of a job remain in memory when the system is low on free
memory. This should be true even for a job in group/container A with
a smooth activity compared to a group/container B with a set of jobs
using memory more agressively...

What happens if we use limits to implement guarantees ?

>> ...
>> The idea of getting a guarantee is simple:
>> if any group gi requires a Gi units of resource from R units available
>> then limiting all the rest groups with R - Gi units provides a desired
>> guarantee

If the limit is a "hard limit" then we have implemented reservation and
this is too strict.

If the limit is a "soft limit" then group/container B is autorized to
use more than the limit and nothing is guaranteed for group/container A...

Patrick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
