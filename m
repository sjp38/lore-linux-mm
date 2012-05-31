Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 4AD8A6B005D
	for <linux-mm@kvack.org>; Thu, 31 May 2012 04:59:08 -0400 (EDT)
Message-ID: <4FC73252.1000106@parallels.com>
Date: Thu, 31 May 2012 12:56:50 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
References: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com> <CAHGf_=pFbsy4FO_UNu6O1-KyTd6O=pkmR8=3EGuZB5Reu3Vb9w@mail.gmail.com> <4FC6BC3E.5010807@jp.fujitsu.com> <alpine.DEB.2.00.1205301737530.25774@chino.kir.corp.google.com> <4FC6C111.2060108@jp.fujitsu.com> <alpine.DEB.2.00.1205301831270.25774@chino.kir.corp.google.com> <4FC6D881.4090706@jp.fujitsu.com> <alpine.DEB.2.00.1205302156090.25774@chino.kir.corp.google.com> <4FC70355.70805@jp.fujitsu.com> <alpine.DEB.2.00.1205302314190.25774@chino.kir.corp.google.com> <4FC70E5E.1010003@gmail.com> <alpine.DEB.2.00.1205302325500.25774@chino.kir.corp.google.com> <4FC711A5.4090003@gmail.com> <alpine.DEB.2.00.1205302351510.25774@chino.kir.corp.google.com> <CAHGf_=qVDVT6VW2j9gE3bQKwizW24iivrDryiCKoxVu4m_fWKw@mail.gmail.com> <alpine.DEB.2.00.1205310028420.8864@chino.kir.corp.google.com> <4FC720EE.3010307@gmail.com> <4FC724B1.70508@cn.fujitsu.com> <4FC72CA4.6080708@parallels.com> <4FC73203.2070009@cn.fujitsu.com>
In-Reply-To: <4FC73203.2070009@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gao feng <gaofeng@cn.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, David Rientjes <rientjes@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org


>>>
>>
>> One think to keep in mind: A file in memcg does not need to follow the same format of /proc/meminfo so we can bind mount. We should be able to reconstruct that in userspace based on information
>> available from the kernel. You can even collect that from multiple locations, and *then* you bind mount.
>>
>> It helps to keep the churn out of the kernel, and in case of meminfo, you might need no extra kernel patches at all. And in the case of other files like /proc/stat, the relevant information comes from
>> more than one cgroup anyway, so there is not too much way around it.
>
> I got it,thank you very much,indeed we need no extra kernel patch at all.
> Maybe we should do this work in lxc or libvirt.
>
> thanks Glauber!
>

lxc has a fuse overlay for /proc already. I can't tell you about the 
state of that, because I haven't looked at it in details yet. I need to 
do something a lot similar for /proc/stat, but that is currently down in 
my prio queue.

But it seems to be the way to go. My only concern is whether or not it 
is usable outside of lxc. Other Container solutions like OpenVZ would
benefit from this a lot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
