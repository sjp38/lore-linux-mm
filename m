Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 59D9A6B005A
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 11:30:53 -0400 (EDT)
Received: by ywh8 with SMTP id 8so6654016ywh.14
        for <linux-mm@kvack.org>; Tue, 15 Sep 2009 08:30:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090915114742.DB79.A69D9226@jp.fujitsu.com>
References: <Pine.LNX.4.64.0909132011550.28745@sister.anvils>
	 <20090915114742.DB79.A69D9226@jp.fujitsu.com>
Date: Wed, 16 Sep 2009 00:30:52 +0900
Message-ID: <28c262360909150830x36de7a28s869c57042a537f24@mail.gmail.com>
Subject: Re: Isolated(anon) and Isolated(file)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 15, 2009 at 11:56 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi
>
>> Hi KOSAKI-san,
>>
>> May I question the addition of Isolated(anon) and Isolated(file)
>> lines to /proc/meminfo? =A0I get irritated by all such "0 kB" lines!
>>
>> I see their appropriateness and usefulness in the Alt-Sysrq-M-style
>> info which accompanies an OOM; and I see that those statistics help
>> you to identify and fix bugs of having too many pages isolated.
>>
>> But IMHO they're too transient to be appropriate in /proc/meminfo:
>> by the time the "cat /proc/meminfo" is done, the situation is very
>> different (or should be once the bugs are fixed).
>>
>> Almost all its numbers are transient, of course, but these seem
>> so much so that I think /proc/meminfo is better off without them
>> (compressing more info into fewer lines).
>>
>> Perhaps I'm in the minority: if others care, what do they think?
>
> I think Alt-Sysrq-M isn't useful in this case. because, if heavy memory
> pressure occur, the administrator can't input "echo > /proc/sysrq-trigger=
"
> to his terminal.
> In the otherhand, many system get /proc/meminfo per every second. then,
> the administrator can see last got statistics.
>
> However, I halfly agree with you. Isolated field is transient value.
> In almost case, it display 0kB. it is a bit annoy.
>
> Fortunately, now /proc/vmstat and /sys/device/system/node/meminfo also
> can display isolated value.
> (As far as I rememberd, it was implemented by Wu's request)
> We can use it. IOW, we can remove isolated field from /proc/meminfo.
>
>
> How about following patch?
>
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D CUT HERE =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> From 7aa6fa2b76ff5d063b8bfa4a3af38c39b9396fd5 Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Tue, 15 Sep 2009 10:16:51 +0900
> Subject: [PATCH] Kill Isolated field in /proc/meminfo
>
> Hugh Dickins pointed out Isolated field dislpay 0kB at almost time.
> It is only increased at heavy memory pressure case.
>
> So, if the system haven't get memory pressure, this field isn't useful.
> And now, we have two alternative way, /sys/device/system/node/node{n}/mem=
info
> and /prov/vmstat. Then, it can be removed.
>
> Reported-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
