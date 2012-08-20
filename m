Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 6047A6B0069
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 03:55:16 -0400 (EDT)
Message-ID: <5031EC9E.1070000@parallels.com>
Date: Mon, 20 Aug 2012 11:51:58 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 00/11] Request for Inclusion: kmem controller for memcg.
References: <1344517279-30646-1-git-send-email-glommer@parallels.com> <CALWz4iycCxuUaEeBz_b8+U13fcCLep3rvuSNUTPD8N-eZkDBrg@mail.gmail.com>
In-Reply-To: <CALWz4iycCxuUaEeBz_b8+U13fcCLep3rvuSNUTPD8N-eZkDBrg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>

On 08/18/2012 01:37 AM, Ying Han wrote:
> On Thu, Aug 9, 2012 at 6:01 AM, Glauber Costa <glommer@parallels.com> wrote:
>> Hi,
>>
>> This is the first part of the kernel memory controller for memcg. It has been
>> discussed many times, and I consider this stable enough to be on tree. A follow
>> up to this series are the patches to also track slab memory. They are not
>> included here because I believe we could benefit from merging them separately
>> for better testing coverage. If there are any issues preventing this to be
>> merged, let me know. I'll be happy to address them.
>>
>> The slab patches are also mature in my self evaluation and could be merged not
>> too long after this. For the reference, the last discussion about them happened
>> at http://lwn.net/Articles/508087/
>>
>> A (throwaway) git tree with them is placed at:
>>
>>         git://github.com/glommer/linux.git kmemcg-slab
> 
> I would like to make a kernel on the tree and run some perf tests on
> it. However the kernel
> doesn't boot due to "divide error: 0000 [#1] SMP".
> https://lkml.org/lkml/2012/5/21/502
> 
> I believe the issue has been fixed ( didn't look through) and can you
> do a rebase on your tree?
> 

Could you please try the branch memcg-3.5/kmemcg-slab instead? It is
rebased on top of the latest mmotm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
