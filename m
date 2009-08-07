Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1D96C6B0055
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 03:54:28 -0400 (EDT)
Received: by an-out-0708.google.com with SMTP id c3so368525ana.26
        for <linux-mm@kvack.org>; Fri, 07 Aug 2009 00:54:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090807120857.5BE2.A69D9226@jp.fujitsu.com>
References: <4A7AC201.4010202@redhat.com> <4A7AD6EB.9090208@redhat.com>
	 <20090807120857.5BE2.A69D9226@jp.fujitsu.com>
Date: Fri, 7 Aug 2009 13:24:34 +0530
Message-ID: <661de9470908070054l2fa99ac6w6cac2be63cd5d91f@mail.gmail.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 7, 2009 at 8:41 AM, KOSAKI
Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
> (cc to memcg folks)
>
>> Avi Kivity wrote:
>> > On 08/06/2009 01:59 PM, Wu Fengguang wrote:
>>
>> >> As a refinement, the static variable 'recent_all_referenced' could be
>> >> moved to struct zone or made a per-cpu variable.
>> >
>> > Definitely this should be made part of the zone structure, consider the
>> > original report where the problem occurs in a 128MB zone (where we can
>> > expect many pages to have their referenced bit set).
>>
>> The problem did not occur in a 128MB zone, but in a 128MB cgroup.
>>
>> Putting it in the zone means that the cgroup, which may have
>> different behaviour from the rest of the zone, due to excessive
>> memory pressure inside the cgroup, does not get the right
>> statistics.
>
> maybe, I heven't catch your point.
>
> Current memcgroup logic also use recent_scan/recent_rotate statistics.
> Isn't it enought?

I don't understand the context, I'll look at the problem when I am
back (I am away from work for the next few days).

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
