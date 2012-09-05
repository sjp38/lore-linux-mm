Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id DFFA66B006E
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 04:20:35 -0400 (EDT)
Message-ID: <50470A87.1040701@parallels.com>
Date: Wed, 5 Sep 2012 12:17:11 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/5] forced comounts for cgroups.
References: <1346768300-10282-1-git-send-email-glommer@parallels.com> <20120904214602.GA9092@dhcp-172-17-108-109.mtv.corp.google.com> <5047074D.1030104@parallels.com> <20120905081439.GC3195@dhcp-172-17-108-109.mtv.corp.google.com>
In-Reply-To: <20120905081439.GC3195@dhcp-172-17-108-109.mtv.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, a.p.zijlstra@chello.nl, pjt@google.com, lennart@poettering.net, kay.sievers@vrfy.org

On 09/05/2012 12:14 PM, Tejun Heo wrote:
> Hello, Glauber.
> 
> On Wed, Sep 05, 2012 at 12:03:25PM +0400, Glauber Costa wrote:
>> The goal here is to have distributions to do it, because they tend to
>> have a well defined lifecycle management, much more than upstream. Whoever
>> sets this option, can coordinate with upstream.
> 
> Distros can just co-mount them during boot.  What's the point of the
> config options?
> 

Pretty simple. The kernel can't assume the distro did. And then we still
need to pay a stupid big price in the scheduler.

After this patchset, We can assume this. And cpuusage can totally be
derived from the cpu cgroup. Because much more than "they can comount",
we can assume they did.

>>> Also, I really don't see much point in enforcing this almost arbitrary
>>> grouping of controllers.  It doesn't simplify anything and using
>>> cpuacct in more granular way than cpu actually is one of the better
>>> justified use of multiple hierarchies.  Also, what about memcg and
>>> blkcg?  Do they *really* coincide?  Note that both blkcg and memcg
>>> involve non-trivial overhead and blkcg is essentially broken
>>> hierarchy-wise.
>>
>> Where did I mention memcg or blkcg in this patch ?
> 
> Differing hierarchies in memcg and blkcg currently is the most
> prominent case where the intersection in writeback is problematic and
> your proposed solution doesn't help one way or the other.  What's the
> point?
> 

The point is that I am focusing at one problem at a time. But FWIW, I
don't see why memcg/blkcg can't use a step just like this one in a
separate pass.

If the goal is comounting them eventually, at some point when the issues
are sorted out, just do it. Get a switch like this one, and then you
will start being able to assume a lot of things in the code. Miracles
can happen.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
