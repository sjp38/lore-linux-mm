Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 5921D6B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 12:10:37 -0500 (EST)
Message-ID: <4F4E5BC5.9010408@parallels.com>
Date: Wed, 29 Feb 2012 14:09:25 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 08/10] memcg: Add CONFIG_CGROUP_MEM_RES_CTLR_KMEM_ACCT_ROOT.
References: <1330383533-20711-1-git-send-email-ssouhlal@FreeBSD.org> <1330383533-20711-9-git-send-email-ssouhlal@FreeBSD.org> <4F4CD7E7.1070901@parallels.com> <CABCjUKAUQZuW9hFeMJ1Oh=0UeS2Ffx4-vHpnaGpjOFu+3KktAA@mail.gmail.com>
In-Reply-To: <CABCjUKAUQZuW9hFeMJ1Oh=0UeS2Ffx4-vHpnaGpjOFu+3KktAA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <suleiman@google.com>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, yinghan@google.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.org, devel@openvz.org

On 02/28/2012 08:36 PM, Suleiman Souhlal wrote:
> On Tue, Feb 28, 2012 at 5:34 AM, Glauber Costa<glommer@parallels.com>  wrote:
>> On 02/27/2012 07:58 PM, Suleiman Souhlal wrote:
>>>
>>> This config option dictates whether or not kernel memory in the
>>> root cgroup should be accounted.
>>>
>>> This may be useful in an environment where everything is supposed to be
>>> in a cgroup and accounted for. Large amounts of kernel memory in the
>>> root cgroup would indicate problems with memory isolation or accounting.
>>
>>
>> I don't like accounting this stuff to the root memory cgroup. This causes
>> overhead for everybody, including people who couldn't care less about memcg.
>>
>> If it were up to me, we would simply not account it, and end of story.
>>
>> However, if this is terribly important for you, I think you need to at
>> least make it possible to enable it at runtime, and default it to disabled.
>
> Yes, that is why I made it a config option. If the config option is
> disabled, that memory does not get accounted at all.

Doesn't work. In reality, most of the distributions enable those stuff 
if there is the possibility that someone will end up using. So everybody 
gets to pay the penalty.

> Making it configurable at runtime is not ideal, because we would
> prefer slab memory that was allocated before cgroups are created to
> still be counted toward root.
>

Again: Why is that you really need it ? Accounting slab to the root 
cgroup feels quite weird to me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
