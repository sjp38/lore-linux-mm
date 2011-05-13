Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D4A126B0011
	for <linux-mm@kvack.org>; Thu, 12 May 2011 20:55:01 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p4D0swHl023723
	for <linux-mm@kvack.org>; Thu, 12 May 2011 17:54:58 -0700
Received: from qwj8 (qwj8.prod.google.com [10.241.195.72])
	by hpaq6.eem.corp.google.com with ESMTP id p4D0sSqO021589
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 May 2011 17:54:57 -0700
Received: by qwj8 with SMTP id 8so1730143qwj.18
        for <linux-mm@kvack.org>; Thu, 12 May 2011 17:54:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DCC7E00.60102@redhat.com>
References: <1305226032-21448-1-git-send-email-yinghan@google.com>
	<4DCC7E00.60102@redhat.com>
Date: Thu, 12 May 2011 17:54:51 -0700
Message-ID: <BANLkTik_z+PKFa2po4WPPyYRD-7-EW1BdA@mail.gmail.com>
Subject: Re: [RFC PATCH 0/4] memcg: revisit soft_limit reclaim on contention
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016e64aefdad71a0604a31dc031
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org, Michel Lespinasse <walken@google.com>

--0016e64aefdad71a0604a31dc031
Content-Type: text/plain; charset=ISO-8859-1

On Thu, May 12, 2011 at 5:40 PM, Rik van Riel <riel@redhat.com> wrote:

> On 05/12/2011 02:47 PM, Ying Han wrote:
>
>  TODO:
>> a) there was a question on how to do zone balancing w/o global LRU. This
>> could be
>> solved by building another cgroup list per-zone, where we also link
>> cgroups under
>> their soft_limit. We won't scan the list unless the first list being
>> exhausted and
>> the free pages is still under the high_wmark.
>>
>
>  b). one of the tricky part is to calculate the target nr_to_scan for each
>> cgroup,
>> especially combining the current heuristics with soft_limit exceeds. it
>> depends how
>> much weight we need to put on the second. One way is to make the ratio to
>> be user
>> configurable.
>>
>
> Johannes addresses these in his patch series.


That would be great, I am reading through his patch and apparently not
getting there yet :)

>
>
>  Ying Han (4):
>>   Disable "organizing cgroups over soft limit in a RB-Tree"
>>   Organize memcgs over soft limit in round-robin.
>>   Implementation of soft_limit reclaim in round-robin.
>>   Add some debugging stats
>>
>
> Looks like you also have some things Johannes doesn't have.
>
> It may be good for the two patch series you have to get
> merged into one series, before stuff gets merged upstream.
>
> Yes, that is my motivation here to post the patch here :)

--Ying

> --
> All rights reversed
>

--0016e64aefdad71a0604a31dc031
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, May 12, 2011 at 5:40 PM, Rik van=
 Riel <span dir=3D"ltr">&lt;<a href=3D"mailto:riel@redhat.com">riel@redhat.=
com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"mar=
gin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">On 05/12/2011 02:47 PM, Ying Han wrote:<br>
<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
TODO:<br>
a) there was a question on how to do zone balancing w/o global LRU. This co=
uld be<br>
solved by building another cgroup list per-zone, where we also link cgroups=
 under<br>
their soft_limit. We won&#39;t scan the list unless the first list being ex=
hausted and<br>
the free pages is still under the high_wmark.<br>
</blockquote>
<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
b). one of the tricky part is to calculate the target nr_to_scan for each c=
group,<br>
especially combining the current heuristics with soft_limit exceeds. it dep=
ends how<br>
much weight we need to put on the second. One way is to make the ratio to b=
e user<br>
configurable.<br>
</blockquote>
<br></div>
Johannes addresses these in his patch series.</blockquote><div><br></div><d=
iv>That would be great, I am reading through his patch and apparently not g=
etting there yet :)=A0</div><blockquote class=3D"gmail_quote" style=3D"marg=
in:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im"><br>
<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
Ying Han (4):<br>
 =A0 Disable &quot;organizing cgroups over soft limit in a RB-Tree&quot;<br=
>
 =A0 Organize memcgs over soft limit in round-robin.<br>
 =A0 Implementation of soft_limit reclaim in round-robin.<br>
 =A0 Add some debugging stats<br>
</blockquote>
<br></div>
Looks like you also have some things Johannes doesn&#39;t have.<br>
<br>
It may be good for the two patch series you have to get<br>
merged into one series, before stuff gets merged upstream.<br><font color=
=3D"#888888">
<br></font></blockquote><div>Yes, that is my motivation here to post the pa=
tch here :)</div><div><br></div><div>--Ying=A0</div><blockquote class=3D"gm=
ail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-le=
ft:1ex;">
<font color=3D"#888888">
-- <br>
All rights reversed<br>
</font></blockquote></div><br>

--0016e64aefdad71a0604a31dc031--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
