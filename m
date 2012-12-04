Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 58A1A6B0044
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 02:40:52 -0500 (EST)
Message-ID: <50BDA8FA.4060404@parallels.com>
Date: Tue, 4 Dec 2012 11:40:42 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] memcg: debugging facility to access dangling memcgs.
References: <1354541048-12597-1-git-send-email-glommer@parallels.com> <20121203154420.661f8e28.akpm@linux-foundation.org>
In-Reply-To: <20121203154420.661f8e28.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>

On 12/04/2012 03:44 AM, Andrew Morton wrote:
> On Mon,  3 Dec 2012 17:24:08 +0400
> Glauber Costa <glommer@parallels.com> wrote:
> 
>> If memcg is tracking anything other than plain user memory (swap, tcp
>> buf mem, or slab memory), it is possible - and normal - that a reference
>> will be held by the group after it is dead. Still, for developers, it
>> would be extremely useful to be able to query about those states during
>> debugging.
>>
>> This patch provides a debugging facility in the root memcg, so we can
>> inspect which memcgs still have pending objects, and what is the cause
>> of this state.
> 
> As this is a developer-only thing, I suggest that we should avoid
> burdening mainline with it.  How about we maintain this in -mm (and
> hence in -next and mhocko's memcg tree) until we no longer see a need
> for it?
> 
I am absolutely fine with that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
