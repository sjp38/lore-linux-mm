Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id E6F2B6B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 14:24:06 -0500 (EST)
Received: by qcsd16 with SMTP id d16so3461345qcs.14
        for <linux-mm@kvack.org>; Wed, 29 Feb 2012 11:24:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F4E5BC5.9010408@parallels.com>
References: <1330383533-20711-1-git-send-email-ssouhlal@FreeBSD.org>
	<1330383533-20711-9-git-send-email-ssouhlal@FreeBSD.org>
	<4F4CD7E7.1070901@parallels.com>
	<CABCjUKAUQZuW9hFeMJ1Oh=0UeS2Ffx4-vHpnaGpjOFu+3KktAA@mail.gmail.com>
	<4F4E5BC5.9010408@parallels.com>
Date: Wed, 29 Feb 2012 11:24:05 -0800
Message-ID: <CABCjUKBFFKap9SfCWDO6ZsA5o+b0152sNhGhckpYG2-f0LaMUw@mail.gmail.com>
Subject: Re: [PATCH 08/10] memcg: Add CONFIG_CGROUP_MEM_RES_CTLR_KMEM_ACCT_ROOT.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, yinghan@google.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.org, devel@openvz.org

On Wed, Feb 29, 2012 at 9:09 AM, Glauber Costa <glommer@parallels.com> wrot=
e:
> On 02/28/2012 08:36 PM, Suleiman Souhlal wrote:
>>
>> On Tue, Feb 28, 2012 at 5:34 AM, Glauber Costa<glommer@parallels.com>
>> =A0wrote:
>>>
>>> On 02/27/2012 07:58 PM, Suleiman Souhlal wrote:
>>>>
>>>>
>>>> This config option dictates whether or not kernel memory in the
>>>> root cgroup should be accounted.
>>>>
>>>> This may be useful in an environment where everything is supposed to b=
e
>>>> in a cgroup and accounted for. Large amounts of kernel memory in the
>>>> root cgroup would indicate problems with memory isolation or accountin=
g.
>>>
>>>
>>>
>>> I don't like accounting this stuff to the root memory cgroup. This caus=
es
>>> overhead for everybody, including people who couldn't care less about
>>> memcg.
>>>
>>> If it were up to me, we would simply not account it, and end of story.
>>>
>>> However, if this is terribly important for you, I think you need to at
>>> least make it possible to enable it at runtime, and default it to
>>> disabled.
>>
>>
>> Yes, that is why I made it a config option. If the config option is
>> disabled, that memory does not get accounted at all.
>
>
> Doesn't work. In reality, most of the distributions enable those stuff if
> there is the possibility that someone will end up using. So everybody get=
s
> to pay the penalty.
>
>
>> Making it configurable at runtime is not ideal, because we would
>> prefer slab memory that was allocated before cgroups are created to
>> still be counted toward root.
>>
>
> Again: Why is that you really need it ? Accounting slab to the root cgrou=
p
> feels quite weird to me

Because, for us, having large amounts of unaccounted memory is a
"bug", and we would like to know when it happens.
Also, we want to know how much memory is actually available in the
machine for jobs (sum of(accounted memory in containers) - unaccounted
kernel memory).

That said, I will drop this patch from the series for now.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
