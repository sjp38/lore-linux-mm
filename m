Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 2ED0D6B0044
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 01:39:24 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id k11so1124805eaa.14
        for <linux-mm@kvack.org>; Wed, 07 Nov 2012 22:39:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <509B533B.7090907@redhat.com>
References: <1352193295-26815-1-git-send-email-mgorman@suse.de>
	<509A2970.9000408@redhat.com>
	<20121107152558.GZ8218@suse.de>
	<509B533B.7090907@redhat.com>
Date: Thu, 8 Nov 2012 14:39:22 +0800
Message-ID: <CAOHXNFG=T63dmc3smkJ2juE7HpxTv6qbavBXycRsXiLBzAwMGw@mail.gmail.com>
Subject: Re: [RFC PATCH 00/19] Foundation for automatic NUMA balancing
From: =?GB2312?B?0e7W8Q==?= <richardyangr@gmail.com>
Content-Type: multipart/alternative; boundary=047d7b621ee2703fd204cdf618c2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhouping Liu <zliu@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, CAI Qian <caiqian@redhat.com>

--047d7b621ee2703fd204cdf618c2
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: quoted-printable

Hi all:
          I got a problem=A3=BA
          1. on intel cpu xeon E5000 family which support xapic =A3=ACone N=
IC
irq  can share on the CPUs basic on smp_affinity.
          2. but on intel cpu xeon E5-2600 family which support x2apic, one
NIC irq only on CPU0 whatever  i set the smp_affinfiy like as "aa"; "55";
"ff".
         My OS is CentOS 6.2  x32 =A3=ACi test 4 cpus=A1=A3 the result is w=
hich only
support apic can share one irq to all cpus=A3=ACwhich support x2apic only m=
ake
the irq to one cpu=A1=A3


want help me

                                                             richard


2012/11/8 Zhouping Liu <zliu@redhat.com>

> On 11/07/2012 11:25 PM, Mel Gorman wrote:
>
>> On Wed, Nov 07, 2012 at 05:27:12PM +0800, Zhouping Liu wrote:
>>
>>> Hello Mel,
>>>
>>> my 2 nodes machine hit a panic fault after applied the patch
>>> set(based on kernel-3.7.0-rc4), please review it:
>>>
>>> <SNIP>
>>>
>> Early initialisation problem by the looks of things. Try this please
>>
>
> Tested the patch, and the issue is gone.
>
>
>> ---8<---
>> mm: numa: Check that preferred_node_policy is initialised
>>
>> Zhouping Liu reported the following
>>
>> [ 0.000000] ------------[ cut here ]------------
>> [ 0.000000] kernel BUG at mm/mempolicy.c:1785!
>> [ 0.000000] invalid opcode: 0000 [#1] SMP
>> [ 0.000000] Modules linked in:
>> [ 0.000000] CPU 0
>> ....
>> [    0.000000] Call Trace:
>> [    0.000000] [<ffffffff81176966>] alloc_pages_current+0xa6/0x170
>> [    0.000000] [<ffffffff81137a44>] __get_free_pages+0x14/0x50
>> [    0.000000] [<ffffffff819efd9b>] kmem_cache_init+0x53/0x2d2
>> [    0.000000] [<ffffffff819caa53>] start_kernel+0x1e0/0x3c7
>>
>> Problem is that early in boot preferred_nod_policy and SLUB
>> initialisation trips up. Check it is initialised.
>>
>> Signed-off-by: Mel Gorman <mgorman@suse.de>
>>
>
> Tested-by: Zhouping Liu <zliu@redhat.com>
>
> Thanks,
> Zhouping
>
>  ---
>>   mm/mempolicy.c |    4 ++++
>>   1 file changed, 4 insertions(+)
>>
>> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>> index 11d4b6b..8cfa6dc 100644
>> --- a/mm/mempolicy.c
>> +++ b/mm/mempolicy.c
>> @@ -129,6 +129,10 @@ static struct mempolicy *get_task_policy(struct
>> task_struct *p)
>>                 node =3D numa_node_id();
>>                 if (node !=3D -1)
>>                         pol =3D &preferred_node_policy[node];
>> +
>> +               /* preferred_node_policy is not initialised early in boo=
t
>> */
>> +               if (!pol->mode)
>> +                       pol =3D NULL;
>>         }
>>         return pol;
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/**majordomo-info.html<http=
://vger.kernel.org/majordomo-info.html>
> Please read the FAQ at  http://www.tux.org/lkml/
>

--047d7b621ee2703fd204cdf618c2
Content-Type: text/html; charset=GB2312
Content-Transfer-Encoding: quoted-printable

<span style=3D"font-family:arial,sans-serif;font-size:14px">Hi all:</span><=
div style=3D"font-family:arial,sans-serif;font-size:14px">&nbsp; &nbsp; &nb=
sp; &nbsp; &nbsp; I got a problem=A3=BA&nbsp;<br>&nbsp; &nbsp; &nbsp; &nbsp=
; &nbsp; 1. on intel cpu xeon E5000 family which support xapic =A3=ACone NI=
C irq &nbsp;can share on the CPUs basic on smp_affinity.&nbsp;</div>
<div style=3D"font-family:arial,sans-serif;font-size:14px">&nbsp; &nbsp; &n=
bsp; &nbsp; &nbsp; 2. but on intel cpu xeon E5-2600 family which support x2=
apic, one NIC irq only on CPU0 whatever &nbsp;i set the smp_affinfiy like a=
s &quot;aa&quot;; &quot;55&quot;; &quot;ff&quot;.</div>
<div style=3D"font-family:arial,sans-serif;font-size:14px">&nbsp; &nbsp; &n=
bsp; &nbsp; &nbsp;My OS is CentOS 6.2 &nbsp;x32 =A3=ACi test 4 cpus=A1=A3 t=
he result is which only support apic can share one irq to all cpus=A3=ACwhi=
ch support x2apic only make the irq to one cpu=A1=A3&nbsp;</div>
<div style=3D"font-family:arial,sans-serif;font-size:14px"><br></div><div s=
tyle=3D"font-family:arial,sans-serif;font-size:14px"><br></div><div style=
=3D"font-family:arial,sans-serif;font-size:14px">want help me</div><div sty=
le=3D"font-family:arial,sans-serif;font-size:14px">
<br></div><div style=3D"font-family:arial,sans-serif;font-size:14px">&nbsp;=
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbs=
p; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &n=
bsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;richard</div><d=
iv class=3D"gmail_extra"><br><br><div class=3D"gmail_quote">2012/11/8 Zhoup=
ing Liu <span dir=3D"ltr">&lt;<a href=3D"mailto:zliu@redhat.com" target=3D"=
_blank">zliu@redhat.com</a>&gt;</span><br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">On 11/07/2012 11:25 PM, Mel Gorman wrote:<br=
>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
On Wed, Nov 07, 2012 at 05:27:12PM +0800, Zhouping Liu wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
Hello Mel,<br>
<br>
my 2 nodes machine hit a panic fault after applied the patch<br>
set(based on kernel-3.7.0-rc4), please review it:<br>
<br>
&lt;SNIP&gt;<br>
</blockquote>
Early initialisation problem by the looks of things. Try this please<br>
</blockquote>
<br>
Tested the patch, and the issue is gone.<br>
<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
<br>
---8&lt;---<br>
mm: numa: Check that preferred_node_policy is initialised<br>
<br>
Zhouping Liu reported the following<br>
<br>
[ 0.000000] ------------[ cut here ]------------<br>
[ 0.000000] kernel BUG at mm/mempolicy.c:1785!<br>
[ 0.000000] invalid opcode: 0000 [#1] SMP<br>
[ 0.000000] Modules linked in:<br>
[ 0.000000] CPU 0<br>
....<br>
[ &nbsp; &nbsp;0.000000] Call Trace:<br>
[ &nbsp; &nbsp;0.000000] [&lt;ffffffff81176966&gt;] alloc_pages_current+0xa=
6/0x170<br>
[ &nbsp; &nbsp;0.000000] [&lt;ffffffff81137a44&gt;] __get_free_pages+0x14/0=
x50<br>
[ &nbsp; &nbsp;0.000000] [&lt;ffffffff819efd9b&gt;] kmem_cache_init+0x53/0x=
2d2<br>
[ &nbsp; &nbsp;0.000000] [&lt;ffffffff819caa53&gt;] start_kernel+0x1e0/0x3c=
7<br>
<br>
Problem is that early in boot preferred_nod_policy and SLUB<br>
initialisation trips up. Check it is initialised.<br>
<br>
Signed-off-by: Mel Gorman &lt;<a href=3D"mailto:mgorman@suse.de" target=3D"=
_blank">mgorman@suse.de</a>&gt;<br>
</blockquote>
<br>
Tested-by: Zhouping Liu &lt;<a href=3D"mailto:zliu@redhat.com" target=3D"_b=
lank">zliu@redhat.com</a>&gt;<br>
<br>
Thanks,<br>
Zhouping<br>
<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
---<br>
&nbsp; mm/mempolicy.c | &nbsp; &nbsp;4 ++++<br>
&nbsp; 1 file changed, 4 insertions(+)<br>
<br>
diff --git a/mm/mempolicy.c b/mm/mempolicy.c<br>
index 11d4b6b..8cfa6dc 100644<br>
--- a/mm/mempolicy.c<br>
+++ b/mm/mempolicy.c<br>
@@ -129,6 +129,10 @@ static struct mempolicy *get_task_policy(struct task_s=
truct *p)<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; node =3D numa_node_=
id();<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if (node !=3D -1)<b=
r>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp=
; &nbsp; pol =3D &amp;preferred_node_policy[node];<br>
+<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; /* preferred_node_policy=
 is not initialised early in boot */<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if (!pol-&gt;mode)<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nb=
sp; pol =3D NULL;<br>
&nbsp; &nbsp; &nbsp; &nbsp; }<br>
&nbsp; &nbsp; &nbsp; &nbsp; return pol;<br>
<br>
--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org" target=3D"_blank">majord=
omo@kvack.org</a>. &nbsp;For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www.linu=
x-mm.org/</a> .<br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
" target=3D"_blank">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kv=
ack.org" target=3D"_blank">email@kvack.org</a> &lt;/a&gt;<br>
</blockquote>
<br>
--<br>
To unsubscribe from this list: send the line &quot;unsubscribe linux-kernel=
&quot; in<br>
the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org" targe=
t=3D"_blank">majordomo@vger.kernel.org</a><br>
More majordomo info at &nbsp;<a href=3D"http://vger.kernel.org/majordomo-in=
fo.html" target=3D"_blank">http://vger.kernel.org/<u></u>majordomo-info.htm=
l</a><br>
Please read the FAQ at &nbsp;<a href=3D"http://www.tux.org/lkml/" target=3D=
"_blank">http://www.tux.org/lkml/</a><br>
</blockquote></div><br></div>

--047d7b621ee2703fd204cdf618c2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
