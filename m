Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f174.google.com (mail-vc0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id B064A6B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 10:01:21 -0400 (EDT)
Received: by mail-vc0-f174.google.com with SMTP id ik5so6660607vcb.33
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 07:01:21 -0700 (PDT)
Received: from mail-ve0-x22f.google.com (mail-ve0-x22f.google.com [2607:f8b0:400c:c01::22f])
        by mx.google.com with ESMTPS id gr1si7932926vdc.92.2014.06.03.07.01.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 07:01:21 -0700 (PDT)
Received: by mail-ve0-f175.google.com with SMTP id jw12so6925768veb.20
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 07:01:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140603110959.GE1321@dhcp22.suse.cz>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
	<20140528121023.GA10735@dhcp22.suse.cz>
	<20140528134905.GF2878@cmpxchg.org>
	<20140528142144.GL9895@dhcp22.suse.cz>
	<20140528152854.GG2878@cmpxchg.org>
	<xr93ioopyj1y.fsf@gthelen.mtv.corp.google.com>
	<20140603110959.GE1321@dhcp22.suse.cz>
Date: Tue, 3 Jun 2014 07:01:20 -0700
Message-ID: <CAHH2K0YuEFdPRVrCfoxYwP5b0GK4cZzL5K3ByubW+087BKcsUg@mail.gmail.com>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
From: Greg Thelen <gthelen@google.com>
Content-Type: multipart/alternative; boundary=20cf307d044c4791d304faeef263
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Roman Gushchin <klamm@yandex-team.ru>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>

--20cf307d044c4791d304faeef263
Content-Type: text/plain; charset=UTF-8

On Jun 3, 2014 4:10 AM, "Michal Hocko" <mhocko@suse.cz> wrote:
>
> On Wed 28-05-14 09:17:13, Greg Thelen wrote:
> [...]
> > My 2c...  The following works for my use cases:
> > 1) introduce memory.low_limit_in_bytes (default=0 thus no default change
> >    from older kernels)
> > 2) interested users will set low_limit_in_bytes to non-zero value.
> >    Memory protected by low limit should be as migratable/reclaimable as
> >    mlock memory.  If a zone full of mlock memory causes oom kills, then
> >    so should the low limit.
>
> Would fallback mode in overcommit or the corner case situation break
> your usecase?

Yes.  Fallback mode would break my use cases.  What is the corner case
situation?  NUMA conflicts?  Low limit is a substitute for users mlocking
memory.  So if mlocked memory has the same NUMA conflicts, then I see no
problem with low limit having the same behavior.

>From a user API perspective, I'm not clear on the difference between
non-ooming (fallback) low limit and the existing soft limit interface.  If
low limit is a "soft" (non ooming) limit then why not rework the existing
soft limit interface and save the low limit for strict (ooming) behavior?

Of course, Google can continue to tweak the soft limit or new low limit to
provide an ooming guarantee rather than violating the limit.

PS: I currently have very limited connectivity so my responses will be
delayed.

--20cf307d044c4791d304faeef263
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"><br>
On Jun 3, 2014 4:10 AM, &quot;Michal Hocko&quot; &lt;<a href=3D"mailto:mhoc=
ko@suse.cz">mhocko@suse.cz</a>&gt; wrote:<br>
&gt;<br>
&gt; On Wed 28-05-14 09:17:13, Greg Thelen wrote:<br>
&gt; [...]<br>
&gt; &gt; My 2c... =C2=A0The following works for my use cases:<br>
&gt; &gt; 1) introduce memory.low_limit_in_bytes (default=3D0 thus no defau=
lt change<br>
&gt; &gt; =C2=A0 =C2=A0from older kernels)<br>
&gt; &gt; 2) interested users will set low_limit_in_bytes to non-zero value=
.<br>
&gt; &gt; =C2=A0 =C2=A0Memory protected by low limit should be as migratabl=
e/reclaimable as<br>
&gt; &gt; =C2=A0 =C2=A0mlock memory. =C2=A0If a zone full of mlock memory c=
auses oom kills, then<br>
&gt; &gt; =C2=A0 =C2=A0so should the low limit.<br>
&gt;<br>
&gt; Would fallback mode in overcommit or the corner case situation break<b=
r>
&gt; your usecase?</p>
<p dir=3D"ltr">Yes.=C2=A0 Fallback mode would break my use cases.=C2=A0 Wha=
t is the corner case situation?=C2=A0 NUMA conflicts?=C2=A0 Low limit is a =
substitute for users mlocking memory.=C2=A0 So if mlocked memory has the sa=
me NUMA conflicts, then I see no problem with low limit having the same beh=
avior.</p>

<p dir=3D"ltr">From a user API perspective, I&#39;m not clear on the differ=
ence between non-ooming (fallback) low limit and the existing soft limit in=
terface.=C2=A0 If low limit is a &quot;soft&quot; (non ooming) limit then w=
hy not rework the existing soft limit interface and save the low limit for =
strict (ooming) behavior?=C2=A0=C2=A0 </p>

<p dir=3D"ltr">Of course, Google can continue to tweak the soft limit or ne=
w low limit to provide an ooming guarantee rather than violating the limit.=
</p>
<p dir=3D"ltr">PS: I currently have very limited connectivity so my respons=
es will be delayed.</p>

--20cf307d044c4791d304faeef263--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
