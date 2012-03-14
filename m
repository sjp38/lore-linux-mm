Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id C67636B004A
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 08:01:06 -0400 (EDT)
Message-ID: <4F608820.8080006@parallels.com>
Date: Wed, 14 Mar 2012 15:59:28 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 03/13] memcg: Uncharge all kmem when deleting a cgroup.
References: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org> <1331325556-16447-4-git-send-email-ssouhlal@FreeBSD.org> <4F5C602B.4050806@parallels.com> <CABCjUKBUQ7QS-pJbzrN=8_AFj20uP+dgOH44AWfK4ZecpprybA@mail.gmail.com>
In-Reply-To: <CABCjUKBUQ7QS-pJbzrN=8_AFj20uP+dgOH44AWfK4ZecpprybA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <suleiman@google.com>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, cl@linux.com, yinghan@google.com, hughd@google.com, gthelen@google.com, peterz@infradead.org, dan.magenheimer@oracle.com, hannes@cmpxchg.org, mgorman@suse.de, James.Bottomley@hansenpartnership.com, linux-mm@kvack.org, devel@openvz.org, linux-kernel@vger.kernel.org


>>> @@ -3719,6 +3721,8 @@ move_account:
>>>                 /* This is for making all *used* pages to be on LRU. */
>>>                 lru_add_drain_all();
>>>                 drain_all_stock_sync(memcg);
>>> +               if (!free_all)
>>> +                       memcg_kmem_move(memcg);
>>
>> Any reason we're not moving kmem charges when free_all is set as well?
>
> Because the slab moving code expects to be synchronized with
> allocations (and itself). We can't call it when there are still tasks
> in the cgroup.

Ok.

Please add an explanation about that.
Oh boy, reading it all now, I started to believe that "free_all" is a 
really poor name =(


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
