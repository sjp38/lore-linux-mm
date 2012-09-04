Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id AF8B36B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 04:33:12 -0400 (EDT)
Message-ID: <5045BBF6.5000900@parallels.com>
Date: Tue, 4 Sep 2012 12:29:42 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] memcg: first step towards hierarchical controller
References: <1346687211-31848-1-git-send-email-glommer@parallels.com> <20120903164148.GS29217@decadent.org.uk>
In-Reply-To: <20120903164148.GS29217@decadent.org.uk>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Dave Jones <davej@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>


> 
>> +	  of the root memcg, regardless of their positioning in the tree.
>> +
>> +	  Use of flat hierarchies is highly discouraged, but has been the
>> +	  default for performance reasons for quite some time. Setting this flag
>> +	  to on will make hierarchical accounting the default. It is still
>> +	  possible to set it back to flat by writing 0 to the file
>> +	  memory.use_hierarchy, albeit discouraged. Distributors are encouraged
>> +	  to set this option.
> [...]
> 
> I don't think that 'default n' is effective encouragement!
> 
> Ben.
> 
If it were up to me, I would just flip it to 1. No option.
A bit of history here, is that people have a - quite valid - concern
that this will disrupt users using their own kernel, should they decide
to update, recompile and run.

Conditional on a Kconfig option, people reusing their .config will see
no change. Distros, otoh, are versioned. It is not unreasonable to
expect a behavior change when a major version flips.

The encouragement here comes not from the default, but from the
acknowledgment that his thing is totally broken, and we need to act to
fix it in a compatible way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
