Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 14AE26B0023
	for <linux-mm@kvack.org>; Wed, 18 May 2011 23:53:28 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p4J3rPTI030813
	for <linux-mm@kvack.org>; Wed, 18 May 2011 20:53:25 -0700
Received: from ywa1 (ywa1.prod.google.com [10.192.1.1])
	by wpaz17.hot.corp.google.com with ESMTP id p4J3rLiD006670
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 May 2011 20:53:24 -0700
Received: by ywa1 with SMTP id 1so964353ywa.0
        for <linux-mm@kvack.org>; Wed, 18 May 2011 20:53:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTimbbCBd0w5MpMCkTixTtukKGnyQCA@mail.gmail.com>
References: <1305766511-11469-1-git-send-email-yinghan@google.com>
	<1305766511-11469-2-git-send-email-yinghan@google.com>
	<20110519101056.ca8e86f6.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimbbCBd0w5MpMCkTixTtukKGnyQCA@mail.gmail.com>
Date: Wed, 18 May 2011 20:53:23 -0700
Message-ID: <BANLkTim+RjBm9_K700UCB5SsvVueTz9wug@mail.gmail.com>
Subject: Re: [PATCH][BUGFIX] memcg: fix a routine for counting pages in node
 (Re: [PATCH V2 2/2] memcg: add memory.numastat api for numa statistics
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cd2574a5dcf8c04a398f243
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0cd2574a5dcf8c04a398f243
Content-Type: text/plain; charset=ISO-8859-1

On Wed, May 18, 2011 at 7:55 PM, Ying Han <yinghan@google.com> wrote:

>
>
> On Wed, May 18, 2011 at 6:10 PM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> On Wed, 18 May 2011 17:55:11 -0700
>> Ying Han <yinghan@google.com> wrote:
>> $ cat /dev/cgroup/memory/memory.numa_stat
>> > total=317674 N0=101850 N1=72552 N2=30120 N3=113142
>> > file=288219 N0=98046 N1=59220 N2=23578 N3=107375
>> > anon=25699 N0=3804 N1=10124 N2=6540 N3=5231
>> >
>> > Note: I noticed <total pages> is not equal to the sum of the rest of
>> counters.
>> > I might need to change the way get that counter, comments are welcomed.
>> >
>>
>> Please debug when you feel strange ;)
>>
>> Here is a fix. Could you test ?
>>
>
> Thanks for the patch. I will test it and post it again.
>

I tested and it doesn't fix the problem. Anyway, I will dig into that from
now.

thanks

--Ying

>
> --Ying
>
>>
>> ==
>> The value for counter base should be initialized. If not,
>> this returns wrong value.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>>  mm/memcontrol.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> Index: mmotm-May11/mm/memcontrol.c
>> ===================================================================
>> --- mmotm-May11.orig/mm/memcontrol.c
>> +++ mmotm-May11/mm/memcontrol.c
>> @@ -710,7 +710,7 @@ static unsigned long
>>  mem_cgroup_get_zonestat_node(struct mem_cgroup *mem, int nid, enum
>> lru_list idx)
>>  {
>>        struct mem_cgroup_per_zone *mz;
>> -       u64 total;
>> +       u64 total = 0;
>>        int zid;
>>
>>        for (zid = 0; zid < MAX_NR_ZONES; zid++) {
>>
>>
>

--000e0cd2574a5dcf8c04a398f243
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, May 18, 2011 at 7:55 PM, Ying Ha=
n <span dir=3D"ltr">&lt;<a href=3D"mailto:yinghan@google.com">yinghan@googl=
e.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"m=
argin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<br><br><div class=3D"gmail_quote"><div class=3D"im">On Wed, May 18, 2011 a=
t 6:10 PM, KAMEZAWA Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kameza=
wa.hiroyu@jp.fujitsu.com" target=3D"_blank">kamezawa.hiroyu@jp.fujitsu.com<=
/a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
On Wed, 18 May 2011 17:55:11 -0700<br>
Ying Han &lt;<a href=3D"mailto:yinghan@google.com" target=3D"_blank">yingha=
n@google.com</a>&gt; wrote:<br>
$ cat /dev/cgroup/memory/memory.numa_stat<br>
&gt; total=3D317674 N0=3D101850 N1=3D72552 N2=3D30120 N3=3D113142<br>
&gt; file=3D288219 N0=3D98046 N1=3D59220 N2=3D23578 N3=3D107375<br>
&gt; anon=3D25699 N0=3D3804 N1=3D10124 N2=3D6540 N3=3D5231<br>
&gt;<br>
&gt; Note: I noticed &lt;total pages&gt; is not equal to the sum of the res=
t of counters.<br>
&gt; I might need to change the way get that counter, comments are welcomed=
.<br>
&gt;<br>
<br>
Please debug when you feel strange ;)<br>
<br>
Here is a fix. Could you test ?<br></blockquote><div><br></div></div><div>T=
hanks for the patch. I will test it and post it again.</div></div></blockqu=
ote><div><br></div><div>I tested and it doesn&#39;t fix the problem. Anyway=
, I will dig into that from now.</div>
<div><br></div><div>thanks</div><div><br></div><div>--Ying</div><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;"><div class=3D"gmail_quote"><div><br></div><font color=
=3D"#888888"><div>
--Ying=A0</div></font><div class=3D"im"><blockquote class=3D"gmail_quote" s=
tyle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">

<br>
=3D=3D<br>
The value for counter base should be initialized. If not,<br>
this returns wrong value.<br>
<br>
Signed-off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.f=
ujitsu.com" target=3D"_blank">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
---<br>
=A0mm/memcontrol.c | =A0 =A02 +-<br>
=A01 file changed, 1 insertion(+), 1 deletion(-)<br>
<br>
Index: mmotm-May11/mm/memcontrol.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- mmotm-May11.orig/mm/memcontrol.c<br>
+++ mmotm-May11/mm/memcontrol.c<br>
@@ -710,7 +710,7 @@ static unsigned long<br>
=A0mem_cgroup_get_zonestat_node(struct mem_cgroup *mem, int nid, enum lru_l=
ist idx)<br>
=A0{<br>
 =A0 =A0 =A0 =A0struct mem_cgroup_per_zone *mz;<br>
- =A0 =A0 =A0 u64 total;<br>
+ =A0 =A0 =A0 u64 total =3D 0;<br>
 =A0 =A0 =A0 =A0int zid;<br>
<br>
 =A0 =A0 =A0 =A0for (zid =3D 0; zid &lt; MAX_NR_ZONES; zid++) {<br>
<br>
</blockquote></div></div><br>
</blockquote></div><br>

--000e0cd2574a5dcf8c04a398f243--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
