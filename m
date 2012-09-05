Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 5A6186B005D
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 04:06:46 -0400 (EDT)
Message-ID: <5047074D.1030104@parallels.com>
Date: Wed, 5 Sep 2012 12:03:25 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/5] forced comounts for cgroups.
References: <1346768300-10282-1-git-send-email-glommer@parallels.com> <20120904214602.GA9092@dhcp-172-17-108-109.mtv.corp.google.com>
In-Reply-To: <20120904214602.GA9092@dhcp-172-17-108-109.mtv.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, a.p.zijlstra@chello.nl, pjt@google.com, lennart@poettering.net, kay.sievers@vrfy.org

On 09/05/2012 01:46 AM, Tejun Heo wrote:
> Hello, Glauber.
> 
> On Tue, Sep 04, 2012 at 06:18:15PM +0400, Glauber Costa wrote:
>> As we have been extensively discussing, the cost and pain points for cgroups
>> come from many places. But at least one of those is the arbitrary nature of
>> hierarchies. Many people, including at least Tejun and me would like this to go
>> away altogether. Problem so far, is breaking compatiblity with existing setups
>>
>> I am proposing here a default-n Kconfig option that will guarantee that the cpu
>> cgroups (for now) will be comounted. I started with them because the
>> cpu/cpuacct division is clearly the worst offender. Also, the default-n is here
>> so distributions will have time to adapt: Forcing this flag to be on without
>> userspace changes will just lead to cgroups failing to mount, which we don't
>> want.
>>
>> Although I've tested it and it works, I haven't compile-tested all possible
>> config combinations. So this is mostly for your eyes. If this gets traction,
>> I'll submit it properly, along with any changes that you might require.
> 
> As I said during the discussion, I'm skeptical about how useful this
> is.  This can't nudge existing users in any meaningfully gradual way.
> Kconfig doesn't make it any better.  It's still an abrupt behavior
> change when seen from userland.
>

The goal here is to have distributions to do it, because they tend to
have a well defined lifecycle management, much more than upstream. Whoever
sets this option, can coordinate with upstream.

Aside from enforcing it, we can pretty much warn() as well, to direct
people towards flipping the switch.

> Also, I really don't see much point in enforcing this almost arbitrary
> grouping of controllers.  It doesn't simplify anything and using
> cpuacct in more granular way than cpu actually is one of the better
> justified use of multiple hierarchies.  Also, what about memcg and
> blkcg?  Do they *really* coincide?  Note that both blkcg and memcg
> involve non-trivial overhead and blkcg is essentially broken
> hierarchy-wise.
> 

Where did I mention memcg or blkcg in this patch ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
