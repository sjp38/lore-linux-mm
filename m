Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 5202C6B0062
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 03:19:33 -0400 (EDT)
Message-ID: <4FED5661.1030102@parallels.com>
Date: Fri, 29 Jun 2012 11:16:49 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: memcg: cat: memory.memsw.* : Operation not supported
References: <2a1a74bf-fbb5-4a6e-b958-44fff8debff2@zmail13.collab.prod.int.phx2.redhat.com> <34bb8049-8007-496c-8ffb-11118c587124@zmail13.collab.prod.int.phx2.redhat.com> <20120627154827.GA4420@tiehlicka.suse.cz> <alpine.DEB.2.00.1206271256120.22162@chino.kir.corp.google.com> <20120627200926.GR15811@google.com> <alpine.DEB.2.00.1206271316070.22162@chino.kir.corp.google.com> <20120627202430.GS15811@google.com> <4FEBD7C0.7090906@jp.fujitsu.com>
In-Reply-To: <4FEBD7C0.7090906@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, Zhouping Liu <zliu@redhat.com>, linux-mm@kvack.org, Li Zefan <lizefan@huawei.com>, CAI Qian <caiqian@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 06/28/2012 08:04 AM, Kamezawa Hiroyuki wrote:
>>
>> I still wish it's folded into CONFIG_MEMCG and conditionalized just on
>> CONFIG_SWAP tho.
>>
> 
> In old days, memsw controller was not very stable. So, we devided the
> config.
> And, it makes size of memory for swap-device double (adds 2bytes per
> swapent.)
> That is the problem.


That's the tendency to happen with anything new, since we want to add it
without disrupting what's already in there. I am not very fond of config
options explosions myself, so I am for removing it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
