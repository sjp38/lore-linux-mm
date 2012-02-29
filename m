Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 95D2D6B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 14:28:57 -0500 (EST)
Received: by qcsd16 with SMTP id d16so3463438qcs.14
        for <linux-mm@kvack.org>; Wed, 29 Feb 2012 11:28:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F4E56A8.4000703@parallels.com>
References: <1330383533-20711-1-git-send-email-ssouhlal@FreeBSD.org>
	<4F4CD0AF.1050508@parallels.com>
	<CABCjUKCQk0RDWH80uQw+SxYsu=1L4GSGBNJWNFD=20o_j8P+ng@mail.gmail.com>
	<4F4E56A8.4000703@parallels.com>
Date: Wed, 29 Feb 2012 11:28:56 -0800
Message-ID: <CABCjUKB5GO18rcr6v=x6=NAOVXKT679OJDQ_NDW+WeUf0N05qg@mail.gmail.com>
Subject: Re: [PATCH 00/10] memcg: Kernel Memory Accounting.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, yinghan@google.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.org, devel@openvz.org

On Wed, Feb 29, 2012 at 8:47 AM, Glauber Costa <glommer@parallels.com> wrote:
> On 02/28/2012 07:47 PM, Suleiman Souhlal wrote:
>> I hadn't considered the fact that two cgroups could have the same base
>> name.
>> I think having a name makes it a lot easier for a human to understand
>> which cgroup is using slab, so what about having both the base name of
>> the cgroup AND its css id, so that the caches are named like
>> "dentry(5:foo)"?
>
>
> That would be better, so if you really want to keep names, I'd advise you to
> go this route.
>
> However, what does "5" really means to whoever is reading that? css ids are
> not visible to the user, so there isn't really too much information you can
> extract for that. So why not only dentry-5 ?

dentry-5 gives even less information.. :-)

>> This should let us use the name of the cgroup while still being able
>> to distiguish cgroups that have the same base name.
>
>
> I am fine with name+css_id if you really want names on it.
>
>
>>> I was thinking: How about we don't bother to show them at all, and
>>> instead,
>>> show a proc-like file inside the cgroup with information about that
>>> cgroup?
>>
>>
>> One of the patches in the series adds a per-memcg memory.kmem.slabinfo.
>
> I know. What I was wondering was if we wanted to show only the non-cgroup
> slabs in /proc/slabinfo, and then show the per-cgroup slabs in the cgroup
> only.

I think /proc/slabinfo should show all the slabs in the system, to
avoid confusion.

Thanks for your comments so far.
I will try to get a v2 out soon that addresses them.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
