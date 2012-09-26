Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 7B2326B0044
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 17:28:08 -0400 (EDT)
Message-ID: <50637298.2090904@parallels.com>
Date: Thu, 27 Sep 2012 01:24:40 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 04/13] kmem accounting basic infrastructure
References: <20120926163648.GO16296@google.com> <50633D24.6020002@parallels.com> <CAOS58YNj-L4ocwn-c27ho4WPW41MKOeJbnLZ8N8r4eUkoxC7GA@mail.gmail.com> <50634105.8060302@parallels.com> <20120926180124.GA12544@google.com> <50634FC9.4090609@parallels.com> <20120926193417.GJ12544@google.com> <50635B9D.8020205@parallels.com> <20120926195648.GA20342@google.com> <50635F46.7000700@parallels.com> <20120926201629.GB20342@google.com>
In-Reply-To: <20120926201629.GB20342@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

On 09/27/2012 12:16 AM, Tejun Heo wrote:
> On Thu, Sep 27, 2012 at 12:02:14AM +0400, Glauber Costa wrote:
>> But think in terms of functionality: This thing here is a lot more
>> similar to swap than use_hierarchy. Would you argue that memsw should be
>> per-root ?
> 
> I'm fairly sure you can make about the same argument about
> use_hierarchy.  There is a choice to make here and one is simpler than
> the other.  I want the additional complexity justified by actual use
> cases which isn't too much to ask for especially when the complexity
> is something visible to userland.
> 
> So let's please stop arguing semantics.  If this is definitely
> necessary for some use cases, sure let's have it.  If not, let's
> consider it later.  I'll stop responding on "inherent differences."  I
> don't think we'll get anywhere with that.
> 

If you stop responding, we are for sure not getting anywhere. I agree
with you here.

Let me point out one issue that you seem to be missing, and you respond
or not, your call.

"kmem_accounted" is not a switch. It is an internal representation only.
The semantics, that we discussed exhaustively in San Diego, is that a
group that is not limited is not accounted. This is simple and consistent.

Since the limits are still per-cgroup, you are actually proposing more
user-visible complexity than me, since you are adding yet another file,
with its own semantics.

About use cases, I've already responded: my containers use case is kmem
limited. There are people like Michal that specifically asked for
user-only semantics to be preserved. So your question for global vs
local switch (that again, doesn't exist; only a local *limit* exists)
should really be posed in the following way:
"Can two different use cases with different needs be hosted in the same
box?"



> Michal, Johannes, Kamezawa, what are your thoughts?
>
waiting! =)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
