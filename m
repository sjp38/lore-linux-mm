Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 87FFD6B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 08:24:28 -0400 (EDT)
Message-ID: <4FEAFADC.8080707@parallels.com>
Date: Wed, 27 Jun 2012 16:21:48 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: + memcg-rename-config-variables.patch added to -mm tree
References: <20120626192108.2BB7FA0329@akpm.mtv.corp.google.com> <20120626195647.GG27816@cmpxchg.org> <4FEAF63D.1090503@parallels.com> <20120627122008.GD5683@tiehlicka.suse.cz>
In-Reply-To: <20120627122008.GD5683@tiehlicka.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, rientjes@google.com, tj@kernel.org, linux-mm@kvack.org

On 06/27/2012 04:20 PM, Michal Hocko wrote:
> On Wed 27-06-12 16:02:05, Glauber Costa wrote:
>> On 06/26/2012 11:56 PM, Johannes Weiner wrote:
>>> On Tue, Jun 26, 2012 at 12:21:07PM -0700, akpm@linux-foundation.org wrote:
>>>>
>>>> The patch titled
>>>>      Subject: memcg: rename config variables
>>>> has been added to the -mm tree.  Its filename is
>>>>      memcg-rename-config-variables.patch
>>>>
>>>> Before you just go and hit "reply", please:
>>>>    a) Consider who else should be cc'ed
>>>>    b) Prefer to cc a suitable mailing list as well
>>>>    c) Ideally: find the original patch on the mailing list and do a
>>>>       reply-to-all to that, adding suitable additional cc's
>>>>
>>>> *** Remember to use Documentation/SubmitChecklist when testing your code ***
>>>>
>>>> The -mm tree is included into linux-next and is updated
>>>> there every 3-4 working days
>>>>
>>>> ------------------------------------------------------
>>>> From: Andrew Morton <akpm@linux-foundation.org>
>>>> Subject: memcg: rename config variables
>>>>
>>>> Sanity:
>>>>
>>>> CONFIG_CGROUP_MEM_RES_CTLR -> CONFIG_MEMCG
>>>> CONFIG_CGROUP_MEM_RES_CTLR_SWAP -> CONFIG_MEMCG_SWAP
>>>> CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED -> CONFIG_MEMCG_SWAP_ENABLED
>>>> CONFIG_CGROUP_MEM_RES_CTLR_KMEM -> CONFIG_MEMCG_KMEM
>>>
>>> Yes!  Thank you.
>>>
>>> When would be the best time to fix the function/variable namespace? :)
>>>
>> Andrew,
>>
>> This patch forgets to convert some users, and my build breaks.
>>
>> In particular, the ones in include/net/sock.h are not converted.
>> There may be others as well, my build break log is quite extensive =p
> 
> I have already sent the missing parts as a follow up email.
> 
Oops, I somehow missed it in my mailbox - or it is delayed.
I've just done the same.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
