Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 0EA626B0069
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 05:33:43 -0400 (EDT)
Message-ID: <50471BAF.2060708@parallels.com>
Date: Wed, 5 Sep 2012 13:30:23 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/5] forced comounts for cgroups.
References: <20120904214602.GA9092@dhcp-172-17-108-109.mtv.corp.google.com> <5047074D.1030104@parallels.com> <20120905081439.GC3195@dhcp-172-17-108-109.mtv.corp.google.com> <50470A87.1040701@parallels.com> <20120905082947.GD3195@dhcp-172-17-108-109.mtv.corp.google.com> <50470EBF.9070109@parallels.com> <20120905084740.GE3195@dhcp-172-17-108-109.mtv.corp.google.com> <1346835993.2600.9.camel@twins> <20120905091140.GH3195@dhcp-172-17-108-109.mtv.corp.google.com> <50471782.6060800@parallels.com> <20120905091925.GJ3195@dhcp-172-17-108-109.mtv.corp.google.com>
In-Reply-To: <20120905091925.GJ3195@dhcp-172-17-108-109.mtv.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, pjt@google.com, lennart@poettering.net, kay.sievers@vrfy.org

On 09/05/2012 01:19 PM, Tejun Heo wrote:
> On Wed, Sep 05, 2012 at 01:12:34PM +0400, Glauber Costa wrote:
>>> No, I never counted out differing granularity.
>>
>> Can you elaborate on which interface do you envision to make it work?
>> They will clearly be mounted in the same hierarchy, or as said
>> alternatively, comounted.
> 
> I'm not sure yet.  At the simplest, mask of controllers which should
> honor (or ignore) nesting beyond the node.  That should be
> understandable enough.  Not sure whether that would be flexible enough
> yet tho.  In the end, they should be comounted but again I don't think
> enforcing comounting at the moment is a step towards that.  It's more
> like a step sideways.
> 

Tejun,

>From the code PoV, guaranteed comounting is what allow us to make
optimizations. "Maybe comounting" will maybe simplify the interface, but
will buy us nothing in the performance level.

I am more than happy to respin it with an added interface for masking
cgroups, if you believe this is a requirement.

But hinting me about what you would like to see on that front would be
really helpful.

Re-asking my question:

cpufreq, clocksources, ftrace, etc, they all use an interface that at
this point can be considered quite standard.

Applying the same logic, each cgroup would have a pair of files:

available_controllers, current_controllers, that you can just control by
writing to.

This can get slightly funny when we consider the right semantics for the
hierarchy, but really, everything will. And it is not like we'll have
anything crazy, we just need to tailor it with care.

If you think there is any chance of this getting us somewhere, I'll code
it. But that would be something to be sent *together* with what I've
just done. As I've said, if we can't guarantee the comounting, we would
still lose all the optimization opportunities.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
