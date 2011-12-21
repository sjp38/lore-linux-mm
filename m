Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id D37016B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 20:00:27 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so7261825vbb.14
        for <linux-mm@kvack.org>; Tue, 20 Dec 2011 17:00:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111220151113.8aa05166.akpm@linux-foundation.org>
References: <1324375503-31487-1-git-send-email-lliubbo@gmail.com>
	<20111220151113.8aa05166.akpm@linux-foundation.org>
Date: Wed, 21 Dec 2011 09:00:26 +0800
Message-ID: <CAA_GA1f3Cc76zu2aZ7yxpiFPchpa+=-ip8adjWBL8X7R-pstKg@mail.gmail.com>
Subject: Re: [RFC][PATCH] memcg: malloc memory for possible node in hotplug
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, hannes@cmpxchg.org, rientjes@google.com, kosaki.motohiro@jp.fujitsu.com, bsingharora@gmail.com

On Wed, Dec 21, 2011 at 7:11 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 20 Dec 2011 18:05:03 +0800
> Bob Liu <lliubbo@gmail.com> wrote:
>
>> Current struct mem_cgroup_per_node and struct mem_cgroup_tree_per_node a=
re
>> malloced for all possible node during system boot.
>>
>> This may cause some memory waste, better if move it to memory hotplug.
>
> This adds a fair bit of complexity for what I suspect is a pretty small
> memory saving. =C2=A0And that memory saving will be on pretty large machi=
nes.
>
> Can you please estimate how much memory this change will save? =C2=A0Taht
> way we can decide whether the additional complexity is worthwhile.
>

Hm, yes, i should get some valuable test result to see whether worth it.

>
> Also, the operations in the new memcg_mem_hotplug_callback() are
> copied-n-pasted from other places in memcontrol.c, such as from
> mem_cgroup_soft_limit_tree_init(). =C2=A0We shouldn't do this - we should=
 be
> able to factor the code so that both mem_cgroup_create() and
> memcg_mem_hotplug_callback() emit simple calls to common helper
> functions.
>
> Thirdly, please don't forget to run scripts/checkpatch.pl!

Sorry for missed that.
Thank you for your review.

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
