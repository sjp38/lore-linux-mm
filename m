Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7CC0F6B0007
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 10:27:02 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id l128so29085264ioe.14
        for <linux-mm@kvack.org>; Mon, 05 Feb 2018 07:27:02 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id a205si2845087itg.53.2018.02.05.07.27.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Feb 2018 07:27:01 -0800 (PST)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w15FNUHH087233
	for <linux-mm@kvack.org>; Mon, 5 Feb 2018 15:27:00 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2130.oracle.com with ESMTP id 2fxr9d0m1r-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 05 Feb 2018 15:27:00 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w15FQwOt027326
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Mon, 5 Feb 2018 15:26:59 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w15FQwbD006201
	for <linux-mm@kvack.org>; Mon, 5 Feb 2018 15:26:58 GMT
Received: by mail-ot0-f172.google.com with SMTP id a2so15845180otf.2
        for <linux-mm@kvack.org>; Mon, 05 Feb 2018 07:26:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <2e02170f-038c-04e6-8dc4-2f68551cf3a1@gmail.com>
References: <20171115141329.ieoqvyoavmv6gnea@techsingularity.net>
 <20171115142816.zxdgkad3ch2bih6d@dhcp22.suse.cz> <20171115144314.xwdi2sbcn6m6lqdo@techsingularity.net>
 <20171115145716.w34jaez5ljb3fssn@dhcp22.suse.cz> <06a33f82-7f83-7721-50ec-87bf1370c3d4@gmail.com>
 <20171116085433.qmz4w3y3ra42j2ih@dhcp22.suse.cz> <20171116100633.moui6zu33ctzpjsf@techsingularity.net>
 <CAOAebxt8ZjfCXND=1=UJQETbjVUGPJVcqKFuwGsrwyM2Mq1dhQ@mail.gmail.com>
 <20171117213206.eekbiiexygig7466@techsingularity.net> <CAOAebxtK=pc+-hpAOtu0GG446F5+t_5xsa_j+p7KAL6HtMc9Qg@mail.gmail.com>
 <20171206105000.4aefxr3uzvutulvb@techsingularity.net> <9ED437F7446DF74B826BE56C7BB1B89E95C1459F@G05USEXSUYA02.g05.fujitsu.local>
 <CAOAebxuHPieDWLyRmPauvuF7dkW=0GeigG=EfWQEb_cgrGgm0Q@mail.gmail.com> <2e02170f-038c-04e6-8dc4-2f68551cf3a1@gmail.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 5 Feb 2018 10:26:57 -0500
Message-ID: <CAOAebxvG5C+u8sNA25+35dw2MBZQb9G8L1MSyhGTtge_U7oP5A@mail.gmail.com>
Subject: Re: [PATCH] mm, meminit: Serially initialise deferred memory if
 trace_buf_size is specified
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masayoshi Mizuma <msys.mizuma@gmail.com>
Cc: Koki.Sanagi@us.fujitsu.com, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steve Sistare <steven.sistare@oracle.com>

Thank you Masayoshi for verifying this work. I will submit it as you suggested.

Pavel

On Mon, Feb 5, 2018 at 9:14 AM, Masayoshi Mizuma <msys.mizuma@gmail.com> wrote:
> Hello Pavel,
>
>> Yes, the patch is here:
>> https://lkml.org/lkml/2018/1/12/600
>
> I tested your patch in my box and it worked well.
> Please feel free to add the following.
>
> Tested-by: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
>
> You may repost the patch after adding your reply for
> Andrew's comment as [PATCH 0/1]...
>
> - Masayoshi
>
> Wed, 31 Jan 2018 13:24:55 -0500 Pavel Tatashin wrote:
>> Hi Koki,
>>
>> Yes, the patch is here:
>> https://lkml.org/lkml/2018/1/12/600
>>
>> It has not been reviewed yet.
>>
>> Pavel
>>
>> On Wed, Jan 31, 2018 at 12:28 PM, Koki.Sanagi@us.fujitsu.com
>> <Koki.Sanagi@us.fujitsu.com> wrote:
>>> Pavel,
>>>
>>> I assume you are working on the fix.
>>> Do you have any progress ?
>>>
>>> Koki
>>>
>>>>> -----Original Message-----
>>>>> From: Mel Gorman [mailto:mgorman@techsingularity.net]
>>>>> Sent: Wednesday, December 06, 2017 5:50 AM
>>>>> To: Pavel Tatashin <pasha.tatashin@oracle.com>
>>>>> Cc: Michal Hocko <mhocko@kernel.org>; YASUAKI ISHIMATSU
>>>>> <yasu.isimatu@gmail.com>; Andrew Morton <akpm@linux-foundation.org>;
>>>>> Linux Memory Management List <linux-mm@kvack.org>; linux-
>>>>> kernel@vger.kernel.org; Sanagi, Koki <Koki.Sanagi@us.fujitsu.com>; Steve
>>>>> Sistare <steven.sistare@oracle.com>
>>>>> Subject: Re: [PATCH] mm, meminit: Serially initialise deferred memory if
>>>>> trace_buf_size is specified
>>>>>
>>>>> On Wed, Nov 29, 2017 at 10:41:59PM -0500, Pavel Tatashin wrote:
>>>>>> Hi Mel,
>>>>>>
>>>>>> Thank you very much for your feedback, my replies below:
>>>>>>
>>>>>>> A lack of involvement from admins is indeed desirable. For example,
>>>>>>> while I might concede on using a disable-everything-switch, I would
>>>>>>> not be happy to introduce a switch that specified how much memory
>>>>>>> per node to initialise.
>>>>>>>
>>>>>>> For the forth approach, I really would be only thinking of a blunt
>>>>>>> "initialise everything instead of going OOM". I was wary of making
>>>>>>> things too complicated and I worried about some side-effects I'll cover later.
>>>>>>
>>>>>> I see, I misunderstood your suggestion. Switching to serial
>>>>>> initialization when OOM works, however, boot time becomes
>>>>>> unpredictable, with some configurations boot is fast with others it is
>>>>>> slow. All of that depends on whether predictions in
>>>>>> reset_deferred_meminit() were good or not which is not easy to debug
>>>>>> for users. Also, overtime predictions in reset_deferred_meminit() can
>>>>>> become very off, and I do not think that we want to continuously
>>>>>> adjust this function.
>>>>>>
>>>>>
>>>>> You could increase the probabilty of a report by doing a WARN_ON_ONCE if the
>>>>> serialised meminit is used.
>>>>>
>>>>>>>> With this approach we could always init a very small amount of
>>>>>>>> struct pages, and allow the rest to be initialized on demand as
>>>>>>>> boot requires until deferred struct pages are initialized. Since,
>>>>>>>> having deferred pages feature assumes that the machine is large,
>>>>>>>> there is no drawback of having some extra byte of dead code,
>>>>>>>> especially that all the checks can be permanently switched of via
>>>>>>>> static branches once deferred init is complete.
>>>>>>>>
>>>>>>>
>>>>>>> This is where I fear there may be dragons. If we minimse the number
>>>>>>> of struct pages and initialise serially as necessary, there is a
>>>>>>> danger that we'll allocate remote memory in cases where local memory
>>>>>>> would have done because a remote node had enough memory.
>>>>>>
>>>>>> True, but is not what we have now has the same issue as well? If one
>>>>>> node is gets out of memory we start using memory from another node,
>>>>>> before deferred pages are initialized?
>>>>>>
>>>>>
>>>>> It's possible but I'm not aware of it happening currently.
>>>>>
>>>>>>  To offset that risk, it would be
>>>>>>> necessary at boot-time to force allocations from local node where
>>>>>>> possible and initialise more memory as necessary. That starts
>>>>>>> getting complicated because we'd need to adjust gfp-flags in the
>>>>>>> fast path with init-and-retry logic in the slow path and that could
>>>>>>> be a constant penalty. We could offset that in the fast path by
>>>>>>> using static branches
>>>>>>
>>>>>> I will try to implement this, and see how complicated the patch will
>>>>>> be, if it gets too complicated for the problem I am trying to solve we
>>>>>> can return to one of your suggestions.
>>>>>>
>>>>>> I was thinking to do something like this:
>>>>>>
>>>>>> Start with every small amount of initialized pages in every node.
>>>>>> If allocation fails, initialize enough struct pages to cover this
>>>>>> particular allocation with struct pages rounded up to section size but
>>>>>> in every single node.
>>>>>>
>>>>>
>>>>> Ok, just make sure it's all in the slow paths of the allocator when the alternative
>>>>> is to fail the allocation.
>>>>>
>>>>>>> but it's getting more and
>>>>>>> more complex for what is a minor optimisation -- shorter boot times
>>>>>>> on large machines where userspace itself could take a *long* time to
>>>>>>> get up and running (think database reading in 1TB of data from disk as it
>>>>> warms up).
>>>>>>
>>>>>> On M6-32 with 32T [1] of memory it saves over 4 minutes of boot time,
>>>>>> and this is on SPARC with 8K pages, on x86 it would be around of 8
>>>>>> minutes because of twice as many pages. This feature improves
>>>>>> availability for larger machines quite a bit. Overtime, systems are
>>>>>> growing, so I expect this feature to become a default configuration in
>>>>>> the next several years on server configs.
>>>>>>
>>>>>
>>>>> Ok, when developing the series originally, I had no machine even close to 32T of
>>>>> memory.
>>>>>
>>>>> --
>>>>> Mel Gorman
>>>>> SUSE Labs
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a hrefmailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
