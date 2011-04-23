Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7128D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 23:49:48 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p3N3nhnS000485
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 20:49:43 -0700
Received: from qwc23 (qwc23.prod.google.com [10.241.193.151])
	by hpaq1.eem.corp.google.com with ESMTP id p3N3nANn016833
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 20:49:42 -0700
Received: by qwc23 with SMTP id 23so466061qwc.3
        for <linux-mm@kvack.org>; Fri, 22 Apr 2011 20:49:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DB24A62.7060602@redhat.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421025107.GG2333@cmpxchg.org>
	<20110421130016.3333cb39.kamezawa.hiroyu@jp.fujitsu.com>
	<20110421050851.GI2333@cmpxchg.org>
	<BANLkTimUQjW_XVdzoLJJwwFDuFvm=Qg_FA@mail.gmail.com>
	<20110423013534.GK2333@cmpxchg.org>
	<BANLkTi=UgLihmoRwdA4E4MXmGc4BmqkqTg@mail.gmail.com>
	<20110423023407.GN2333@cmpxchg.org>
	<BANLkTimwMcBwTvi8aNDPXkS_Vu+bxdciMg@mail.gmail.com>
	<4DB24A62.7060602@redhat.com>
Date: Fri, 22 Apr 2011 20:49:41 -0700
Message-ID: <BANLkTi=A+SD_V_ag3z97w1eA1QfbAqAbAg@mail.gmail.com>
Subject: Re: [PATCH V6 00/10] memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016364eec7e44d32704a18ddd37
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--0016364eec7e44d32704a18ddd37
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Apr 22, 2011 at 8:41 PM, Rik van Riel <riel@redhat.com> wrote:

> On 04/22/2011 11:33 PM, Ying Han wrote:
>
>  Now we would like to launch another job C, since we know there are A(16G
>> - 10G) + B(16G - 10G)  = 12G "cold" memory can be reclaimed (w/o
>> impacting the A and B's performance). So what will happen
>>
>> 1. start running C on the host, which triggers global memory pressure
>> right away. If the reclaim is fast, C start growing with the free pages
>> from A and B.
>>
>> However, it might be possible that the reclaim can not catch-up with the
>> job's page allocation. We end up with either OOM condition or
>> performance spike on any of the running jobs.
>>
>> One way to improve it is to set a wmark on either A/B to be proactively
>> reclaiming pages before launching C. The global memory pressure won't
>> help much here since we won't trigger that.
>>
>>    min_free_kbytes more or less indirectly provides the same on a global
>>    level, but I don't think anybody tunes it just for aggressiveness of
>>    background reclaim.
>>
>
> This sounds like yet another reason to have a tunable that
> can increase the gap between min_free_kbytes and low_free_kbytes
> (automatically scaled to size in every zone).
>
> The realtime people want this to reduce allocation latencies.
>
> I want it for dynamic virtual machine resizing, without the
> memory fragmentation inherent in balloons (which would destroy
> the performance benefit of transparent hugepages).
>
> Now Google wants it for job placement.
>

To clarify a bit, we scale the min_free_kbytes to reduce the likelyhood of
page allocation failure. This is still the global per-zone page allocation,
and is different from the memcg discussion we have in this thread. To be
more specific, our case is more or less caused by the 128M fake node size.

Anyway, this is different from what have been discussed so far on this
thread. :)

--Ying

>
> Is there any good reason we can't have a low watermark
> equivalent to min_free_kbytes? :)
>
> --
> All rights reversed
>

--0016364eec7e44d32704a18ddd37
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, Apr 22, 2011 at 8:41 PM, Rik van=
 Riel <span dir=3D"ltr">&lt;<a href=3D"mailto:riel@redhat.com">riel@redhat.=
com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"mar=
gin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">On 04/22/2011 11:33 PM, Ying Han wrote:<br>
<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
Now we would like to launch another job C, since we know there are A(16G<br=
>
- 10G) + B(16G - 10G) =A0=3D 12G &quot;cold&quot; memory can be reclaimed (=
w/o<br>
impacting the A and B&#39;s performance). So what will happen<br>
<br>
1. start running C on the host, which triggers global memory pressure<br>
right away. If the reclaim is fast, C start growing with the free pages<br>
from A and B.<br>
<br>
However, it might be possible that the reclaim can not catch-up with the<br=
>
job&#39;s page allocation. We end up with either OOM condition or<br>
performance spike on any of the running jobs.<br>
<br>
One way to improve it is to set a wmark on either A/B to be proactively<br>
reclaiming pages before launching C. The global memory pressure won&#39;t<b=
r>
help much here since we won&#39;t trigger that.<br>
<br>
 =A0 =A0min_free_kbytes more or less indirectly provides the same on a glob=
al<br>
 =A0 =A0level, but I don&#39;t think anybody tunes it just for aggressivene=
ss of<br>
 =A0 =A0background reclaim.<br>
</blockquote>
<br></div>
This sounds like yet another reason to have a tunable that<br>
can increase the gap between min_free_kbytes and low_free_kbytes<br>
(automatically scaled to size in every zone).<br>
<br>
The realtime people want this to reduce allocation latencies.<br>
<br>
I want it for dynamic virtual machine resizing, without the<br>
memory fragmentation inherent in balloons (which would destroy<br>
the performance benefit of transparent hugepages).<br>
<br>
Now Google wants it for job placement.<br></blockquote><div><br></div><div>=
To clarify a bit, we scale the min_free_kbytes to reduce the likelyhood of =
page allocation failure. This is still the global per-zone page allocation,=
 and is different from the memcg discussion we have in this thread. To be m=
ore specific, our case is more or less caused by the 128M fake node size.</=
div>
<div><br></div><div>Anyway, this is different from what have been discussed=
 so far on this thread. :)</div><div><br></div><div>--Ying</div><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">

<br>
Is there any good reason we can&#39;t have a low watermark<br>
equivalent to min_free_kbytes? :)<br><font color=3D"#888888">
<br>
-- <br>
All rights reversed<br>
</font></blockquote></div><br>

--0016364eec7e44d32704a18ddd37--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
