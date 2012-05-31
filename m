Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 8CC246B005D
	for <linux-mm@kvack.org>; Thu, 31 May 2012 04:54:14 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A359F3EE0BC
	for <linux-mm@kvack.org>; Thu, 31 May 2012 17:54:12 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8ADB445DEB3
	for <linux-mm@kvack.org>; Thu, 31 May 2012 17:54:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 70E8E45DEB2
	for <linux-mm@kvack.org>; Thu, 31 May 2012 17:54:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 63BE61DB8042
	for <linux-mm@kvack.org>; Thu, 31 May 2012 17:54:12 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E917D1DB8041
	for <linux-mm@kvack.org>; Thu, 31 May 2012 17:54:11 +0900 (JST)
Message-ID: <4FC73110.6010107@jp.fujitsu.com>
Date: Thu, 31 May 2012 17:51:28 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
References: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com> <4FC6B68C.2070703@jp.fujitsu.com> <CAHGf_=pFbsy4FO_UNu6O1-KyTd6O=pkmR8=3EGuZB5Reu3Vb9w@mail.gmail.com> <4FC6BC3E.5010807@jp.fujitsu.com> <alpine.DEB.2.00.1205301737530.25774@chino.kir.corp.google.com> <4FC6C111.2060108@jp.fujitsu.com> <alpine.DEB.2.00.1205301831270.25774@chino.kir.corp.google.com> <4FC6D881.4090706@jp.fujitsu.com> <alpine.DEB.2.00.1205302156090.25774@chino.kir.corp.google.com> <4FC70355.70805@jp.fujitsu.com> <alpine.DEB.2.00.1205302314190.25774@chino.kir.corp.google.com> <4FC70E5E.1010003@gmail.com> <alpine.DEB.2.00.1205302325500.25774@chino.kir.corp.google.com> <4FC711A5.4090003@gmail.com> <alpine.DEB.2.00.1205302351510.25774@chino.kir.corp.google.com> <CAHGf_=qVDVT6VW2j9gE3bQKwizW24iivrDryiCKoxVu4m_fWKw@mail.gmail.com> <alpine.DEB.2.00.1205310028420.8864@chino.kir.corp.google.com> <4FC720EE.3010307@gmail.com> <4FC724B1.70508@cn.fujitsu.com> <4FC72CA4.6080708@parallels.com>
In-Reply-To: <4FC72CA4.6080708@parallels.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, David Rientjes <rientjes@google.com>, hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org

(2012/05/31 17:32), Glauber Costa wrote:
> On 05/31/2012 11:58 AM, Gao feng wrote:
>>> > It's one of a option. But, I seriously doubt fuse can make simpler than kamezawa-san's
>>> > idea. But yeah, I might NACK kamezawa-san's one if he will post ugly patch.
>>> >
>> It seams I should do some homework to make the implement beautifully.
>>
>> I think kamezawa-san's idea is more simpler.
>> thanks for your advice.
>>
>
> One think to keep in mind: A file in memcg does not need to follow the same format
> of /proc/meminfo so we can bind mount. We should be able to reconstruct that in
>  userspace based on information available from the kernel. You can even collect that
>from multiple locations, and *then* you bind mount.

I'm sorry I couldn't fully understand. Could you explain more ?
Do you mean
  - bind mount memory cgroup directory into the container for exporting information
  - Some user-space apps, FUSE-procfs or some, can provide enough information

?
Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
