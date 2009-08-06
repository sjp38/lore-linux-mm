Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4972E6B005D
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 09:44:10 -0400 (EDT)
Message-ID: <4A7ADF78.20105@redhat.com>
Date: Thu, 06 Aug 2009 16:49:44 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
References: <20090805024058.GA8886@localhost> <20090805155805.GC23385@random.random> <20090806100824.GO23385@random.random> <4A7AAE07.1010202@redhat.com> <20090806102057.GQ23385@random.random> <20090806105932.GA1569@localhost> <4A7AC201.4010202@redhat.com> <4A7AD6EB.9090208@redhat.com>
In-Reply-To: <4A7AD6EB.9090208@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 08/06/2009 04:13 PM, Rik van Riel wrote:
> Avi Kivity wrote:
>> On 08/06/2009 01:59 PM, Wu Fengguang wrote:
>
>>> As a refinement, the static variable 'recent_all_referenced' could be
>>> moved to struct zone or made a per-cpu variable.
>>
>> Definitely this should be made part of the zone structure, consider 
>> the original report where the problem occurs in a 128MB zone (where 
>> we can expect many pages to have their referenced bit set).
>
> The problem did not occur in a 128MB zone, but in a 128MB cgroup.
>
> Putting it in the zone means that the cgroup, which may have
> different behaviour from the rest of the zone, due to excessive
> memory pressure inside the cgroup, does not get the right
> statistics.
>

Well, it should be per inactive list, whether it's a zone or a cgroup.  
What's the name of this thing? ("inactive list"?)

error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
