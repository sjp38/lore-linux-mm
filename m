Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 26CA46B002E
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 15:58:49 -0400 (EDT)
Message-ID: <4E95F167.5050709@redhat.com>
Date: Wed, 12 Oct 2011 15:58:31 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -v2 -mm] add extra free kbytes tunable
References: <20110901105208.3849a8ff@annuminas.surriel.com> <20110901100650.6d884589.rdunlap@xenotime.net> <20110901152650.7a63cb8b@annuminas.surriel.com> <alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com> <20111010153723.6397924f.akpm@linux-foundation.org> <65795E11DBF1E645A09CEC7EAEE94B9CB516CBC4@USINDEVS02.corp.hds.com> <20111011125419.2702b5dc.akpm@linux-foundation.org> <65795E11DBF1E645A09CEC7EAEE94B9CB516CBFE@USINDEVS02.corp.hds.com> <20111011135445.f580749b.akpm@linux-foundation.org> <4E95917D.3080507@redhat.com> <20111012122018.690bdf28.akpm@linux-foundation.org>
In-Reply-To: <20111012122018.690bdf28.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Satoru Moriya <satoru.moriya@hds.com>, David Rientjes <rientjes@google.com>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, "hughd@google.com" <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On 10/12/2011 03:20 PM, Andrew Morton wrote:
> On Wed, 12 Oct 2011 09:09:17 -0400
> Rik van Riel<riel@redhat.com>  wrote:

>> The problem is that we may be dealing with bursts, not steady
>> states of allocations.  Without knowing the size of a burst,
>> we have no idea when we should wake up kswapd to get enough
>> memory freed ahead of the application's allocations.
>
> That problem remains with this patch - it just takes a larger burst.
>
> Unless the admin somehow manages to configure the tunable large enough
> to cover the largest burst, and there aren't other applications
> allocating memory during that burst, and the time between bursts is
> sufficient for kswapd to be able to sufficiently replenish free-page
> reserves.  All of which sounds rather unlikely.

It depends on the system. For a setup which is packed to
the brim with workloads, this patch is not likely to help.
On the other hand, on a system that is packed to the brim
with workloads, you are unlikely to get low latencies anyway.

For situations where people really care about low latencies,
I imagine having dedicated hardware for a workload is not at
all unusual, and the patch works for that.

>>> Look, please don't go bending over backwards like this to defend a bad
>>> patch.  It's a bad patch!  It would be better not to have to merge it.
>>> Let's do something better.
>>
>> I would love it if we could come up with something better,
>> and have thought about it a lot.
>>
>> However, so far we do not seem to have an alternative yet :(
>
> Do we actually have a real-world application which is hurting from
> this?

Satoru-san?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
