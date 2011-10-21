Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 500946B002D
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 16:00:26 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p9LK0NA1021804
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 13:00:23 -0700
Received: from qyc1 (qyc1.prod.google.com [10.241.81.129])
	by hpaq13.eem.corp.google.com with ESMTP id p9LK0J6L021422
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 13:00:21 -0700
Received: by qyc1 with SMTP id 1so5941413qyc.10
        for <linux-mm@kvack.org>; Fri, 21 Oct 2011 13:00:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20111021121759.429d8222.kamezawa.hiroyu@jp.fujitsu.com>
References: <20111020013305.GD21703@tiehlicka.suse.cz>
	<CALWz4ixxeFveibvqYa4cQR1a4fEBrTrTUFwm2iajk9mV0MEiTw@mail.gmail.com>
	<20111021024554.GC2589@tiehlicka.suse.cz>
	<20111021121759.429d8222.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 21 Oct 2011 13:00:18 -0700
Message-ID: <CALWz4iw9OGUNKjD5y2xGDGaesTjwUT5TOL2A7wDd5apy4M5fnw@mail.gmail.com>
Subject: Re: [RFD] Isolated memory cgroups again
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=001636426b15bbfe6704afd4851d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, Kir Kolyshkin <kir@parallels.com>, Pavel Emelianov <xemul@parallels.com>, GregThelen <gthelen@google.com>, "pjt@google.com" <pjt@google.com>, Tim Hockin <thockin@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Paul Menage <paul@paulmenage.org>, James Bottomley <James.Bottomley@hansenpartnership.com>

--001636426b15bbfe6704afd4851d
Content-Type: text/plain; charset=ISO-8859-1

On Thursday, October 20, 2011, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 20 Oct 2011 19:45:55 -0700
> Michal Hocko <mhocko@suse.cz> wrote:
>
>> On Thu 20-10-11 16:41:27, Ying Han wrote:
>> [...]
>> > Hi Michal:
>>
>> Hi,
>>
>> >
>> > I didn't read through the patch itself but only the description. If we
>> > wanna protect a memcg being reclaimed from under global memory
>> > pressure, I think we can approach it by making change on soft_limit
>> > reclaim.
>> >
>> > I have a soft_limit change built on top of Johannes's patchset, which
>> > does basically soft_limit aware reclaim under global memory pressure.
>>
>> Is there any link to the patch(es)? I would be interested to look at
>> it before we discuss it.
>>
>
> I'd like to see it, too.
>
> Thanks,
> -Kame
>
Now I am at airport heading to Prague , I will try to post one before the
meeting if possible. The current patch is simple enough which most of the
work are reverting the existing soft limit implementation and then the new
logic is based on the memcg aware global reclaim.

The logic is based on reclaim priority, and we skip reclaim from certain
memcg(under soft limit) before getting down to DEF_PRIORITY - 3. This is
simple enough to get us start collecting some data result and I am looking
forward to discuss more thoughts in the meeting


--ying

--001636426b15bbfe6704afd4851d
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br>On Thursday, October 20, 2011, KAMEZAWA Hiroyuki &lt;<a href=3D"mai=
lto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt; =
wrote:<br>&gt; On Thu, 20 Oct 2011 19:45:55 -0700<br>&gt; Michal Hocko &lt;=
<a href=3D"mailto:mhocko@suse.cz">mhocko@suse.cz</a>&gt; wrote:<br>
&gt;<br>&gt;&gt; On Thu 20-10-11 16:41:27, Ying Han wrote:<br>&gt;&gt; [...=
]<br>&gt;&gt; &gt; Hi Michal:<br>&gt;&gt;<br>&gt;&gt; Hi,<br>&gt;&gt;<br>&g=
t;&gt; &gt;<br>&gt;&gt; &gt; I didn&#39;t read through the patch itself but=
 only the description. If we<br>
&gt;&gt; &gt; wanna protect a memcg being reclaimed from under global memor=
y<br>&gt;&gt; &gt; pressure, I think we can approach it by making change on=
 soft_limit<br>&gt;&gt; &gt; reclaim.<br>&gt;&gt; &gt;<br>&gt;&gt; &gt; I h=
ave a soft_limit change built on top of Johannes&#39;s patchset, which<br>
&gt;&gt; &gt; does basically soft_limit aware reclaim under global memory p=
ressure.<br>&gt;&gt;<br>&gt;&gt; Is there any link to the patch(es)? I woul=
d be interested to look at<br>&gt;&gt; it before we discuss it.<br>&gt;&gt;=
<br>
&gt;<br>&gt; I&#39;d like to see it, too.<br>&gt;<br>&gt; Thanks,<br>&gt; -=
Kame<br>&gt;<br>Now I am at airport heading to Prague , I will try to post =
one before the meeting if possible. The current patch is simple enough whic=
h most of the work are reverting the existing soft limit implementation and=
 then the new logic is based on the memcg aware global reclaim.<br>
<br>The logic is based on reclaim priority, and we skip reclaim from certai=
n memcg(under soft limit) before getting down to DEF_PRIORITY - 3. This is =
simple enough to get us start collecting some data result and I am looking =
forward to discuss more thoughts in the meeting<br>
<br><br>--ying=20

--001636426b15bbfe6704afd4851d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
