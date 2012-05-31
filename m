Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id B84A96B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 03:42:41 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so442371qcs.14
        for <linux-mm@kvack.org>; Thu, 31 May 2012 00:42:40 -0700 (PDT)
Message-ID: <4FC720EE.3010307@gmail.com>
Date: Thu, 31 May 2012 03:42:38 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
References: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com> <alpine.DEB.2.00.1205301433490.9716@chino.kir.corp.google.com> <4FC6B68C.2070703@jp.fujitsu.com> <CAHGf_=pFbsy4FO_UNu6O1-KyTd6O=pkmR8=3EGuZB5Reu3Vb9w@mail.gmail.com> <4FC6BC3E.5010807@jp.fujitsu.com> <alpine.DEB.2.00.1205301737530.25774@chino.kir.corp.google.com> <4FC6C111.2060108@jp.fujitsu.com> <alpine.DEB.2.00.1205301831270.25774@chino.kir.corp.google.com> <4FC6D881.4090706@jp.fujitsu.com> <alpine.DEB.2.00.1205302156090.25774@chino.kir.corp.google.com> <4FC70355.70805@jp.fujitsu.com> <alpine.DEB.2.00.1205302314190.25774@chino.kir.corp.google.com> <4FC70E5E.1010003@gmail.com> <alpine.DEB.2.00.1205302325500.25774@chino.kir.corp.google.com> <4FC711A5.4090003@gmail.com> <alpine.DEB.2.00.1205302351510.25774@chino.kir.corp.google.com> <CAHGf_=qVDVT6VW2j9gE3bQKwizW24iivrDryiCKoxVu4m_fWKw@mail.gmail.com> <alpine.DEB.2.00.1205310028420.8864@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1205310028420.8864@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Gao feng <gaofeng@cn.fujitsu.com>, hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org

(5/31/12 3:35 AM), David Rientjes wrote:
> On Thu, 31 May 2012, KOSAKI Motohiro wrote:
>
>>> As I said, LXC and namespace isolation is a tangent to the discussion of
>>> faking the /proc/meminfo for the memcg context of a thread.
>>
>> Because of, /proc/meminfo affect a lot of libraries behavior. So, it's not only
>> application issue. If you can't rewrite _all_ of userland assets, fake meminfo
>> can't be escaped. Again see alternative container implementation.
>>
>
> It's a tangent because it isn't a complete psuedo /proc/meminfo for all
> threads attached to a memcg regardless of any namespace isolation; the LXC
> solution has existed for a couple of years by its procfs patchset that
> overlaps procfs with fuse and can suppress or modify any output in the
> context of a memory controller using things like
> memory.{limit,usage}_in_bytes.  I'm sure all other fields could be
> modified if outputted in some structured way via memcg; it looks like
> memory.stat would need to be extended to provide that.  If that's mounted
> prior to executing the application, then your isolation is achieved and
> all libraries should see the new output that you've defined in LXC.
>
> However, this seems like a seperate topic than the patch at hand which
> does this directly to /proc/meminfo based on a thread's memcg context,
> that's the part that I'm nacking.

Then, I NAKed current patch too. Yeah, current one is ugly. It assume _all_
user need namespace isolation and it clearly is not.


> I'd recommend to Gao to expose this
> information via memory.stat and then use fuse and the procfs lxc support
> as your way of contextualizing the resources.

It's one of a option. But, I seriously doubt fuse can make simpler than kamezawa-san's
idea. But yeah, I might NACK kamezawa-san's one if he will post ugly patch.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
