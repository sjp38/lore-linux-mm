Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DE98C8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 00:31:45 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p3L4VfG8025904
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 21:31:42 -0700
Received: from qwf6 (qwf6.prod.google.com [10.241.194.70])
	by wpaz9.hot.corp.google.com with ESMTP id p3L4VeJQ022303
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 21:31:40 -0700
Received: by qwf6 with SMTP id 6so887612qwf.30
        for <linux-mm@kvack.org>; Wed, 20 Apr 2011 21:31:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTin7BDchrD_L+UFBwsyn2oAbuU03qA@mail.gmail.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421124059.79990661.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTin7BDchrD_L+UFBwsyn2oAbuU03qA@mail.gmail.com>
Date: Wed, 20 Apr 2011 21:31:40 -0700
Message-ID: <BANLkTim-VhrwhNBiWVNspknXT=iB2rXY_w@mail.gmail.com>
Subject: Re: [PATCH V6 00/10] memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016360e3f5cb4f4fa04a1663709
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--0016360e3f5cb4f4fa04a1663709
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Apr 20, 2011 at 9:22 PM, Ying Han <yinghan@google.com> wrote:

>
>
> On Wed, Apr 20, 2011 at 8:40 PM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> On Mon, 18 Apr 2011 20:57:36 -0700
>> Ying Han <yinghan@google.com> wrote:
>>
>> > 1. there are one kswapd thread per cgroup. the thread is created when
>> the
>> > cgroup changes its limit_in_bytes and is deleted when the cgroup is
>> being
>> > removed. In some enviroment when thousand of cgroups are being
>> configured on
>> > a single host, we will have thousand of kswapd threads. The memory
>> consumption
>> > would be 8k*100 = 8M. We don't see a big issue for now if the host can
>> host
>> > that many of cgroups.
>> >
>>
>> I don't think no-fix to this is ok.
>>
>> Here is a thread pool patch on your set. (and includes some more).
>> 3 patches in following e-mails.
>> Any comments are welocme, but my response may be delayed.
>>
>> Thank you for making up the patch, and I will take a look. Do I apply the
> 3 patches on top of my patchset or they comes separately?
>

Sorry, please ignore my last question. Looks like the patch are based on my
existing per-memcg kswapd patchset. I will try to apply it.

--Ying

>
> --Ying
>
> Thanks,
>> -Kame
>>
>>
>>
>

--0016360e3f5cb4f4fa04a1663709
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Apr 20, 2011 at 9:22 PM, Ying Ha=
n <span dir=3D"ltr">&lt;<a href=3D"mailto:yinghan@google.com">yinghan@googl=
e.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"m=
argin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<br><br><div class=3D"gmail_quote"><div><div></div><div class=3D"h5">On Wed=
, Apr 20, 2011 at 8:40 PM, KAMEZAWA Hiroyuki <span dir=3D"ltr">&lt;<a href=
=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com" target=3D"_blank">kamezawa.hiroy=
u@jp.fujitsu.com</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
<div>On Mon, 18 Apr 2011 20:57:36 -0700<br>
Ying Han &lt;<a href=3D"mailto:yinghan@google.com" target=3D"_blank">yingha=
n@google.com</a>&gt; wrote:<br>
<br>
&gt; 1. there are one kswapd thread per cgroup. the thread is created when =
the<br>
&gt; cgroup changes its limit_in_bytes and is deleted when the cgroup is be=
ing<br>
&gt; removed. In some enviroment when thousand of cgroups are being configu=
red on<br>
&gt; a single host, we will have thousand of kswapd threads. The memory con=
sumption<br>
&gt; would be 8k*100 =3D 8M. We don&#39;t see a big issue for now if the ho=
st can host<br>
&gt; that many of cgroups.<br>
&gt;<br>
<br>
</div>I don&#39;t think no-fix to this is ok.<br>
<br>
Here is a thread pool patch on your set. (and includes some more).<br>
3 patches in following e-mails.<br>
Any comments are welocme, but my response may be delayed.<br>
<br></blockquote></div></div><div>Thank you for making up the patch, and I =
will take a look. Do I apply the 3 patches on top of my patchset or they co=
mes=A0separately?</div></div></blockquote><div><br></div><div>Sorry, please=
 ignore my last question. Looks like the patch are based on my existing per=
-memcg kswapd patchset. I will try to apply it.</div>
<div><br></div><div>--Ying=A0</div><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;"><div cl=
ass=3D"gmail_quote"><div>=A0</div><div>--Ying</div><div><br></div><blockquo=
te class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc so=
lid;padding-left:1ex">


Thanks,<br>
-Kame<br>
<br>
<br>
</blockquote></div><br>
</blockquote></div><br>

--0016360e3f5cb4f4fa04a1663709--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
