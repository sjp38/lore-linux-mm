Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 14AC16B004A
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 11:13:14 -0500 (EST)
Received: by qcsd16 with SMTP id d16so3114936qcs.14
        for <linux-mm@kvack.org>; Tue, 06 Mar 2012 08:13:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F55E8BB.5060704@parallels.com>
References: <1330383533-20711-1-git-send-email-ssouhlal@FreeBSD.org>
	<1330383533-20711-5-git-send-email-ssouhlal@FreeBSD.org>
	<20120229150041.62c1feeb.kamezawa.hiroyu@jp.fujitsu.com>
	<CABCjUKBHjLHKUmW6_r0SOyw42WfV0zNO7Kd7FhhRQTT6jZdyeQ@mail.gmail.com>
	<20120301091044.1a62d42c.kamezawa.hiroyu@jp.fujitsu.com>
	<4F4EC1AB.8050506@parallels.com>
	<20120301150537.8996bbf6.kamezawa.hiroyu@jp.fujitsu.com>
	<4F522910.1050402@parallels.com>
	<CABCjUKBngJx0o5jnJk3FEjWUDA6aNTAiFENdEF+M7BwB85NaLg@mail.gmail.com>
	<4F52A81A.3030408@parallels.com>
	<CABCjUKBP=pKgDP5RkD4BimTjoE=bQQO7NxNNAiGUfy602T4c7A@mail.gmail.com>
	<4F55E8BB.5060704@parallels.com>
Date: Tue, 6 Mar 2012 08:13:12 -0800
Message-ID: <CABCjUKD6_7p_OvsSPOJi9q4WRcHVhn3Y-R=dndomNLb13fVApA@mail.gmail.com>
Subject: Re: [PATCH 04/10] memcg: Introduce __GFP_NOACCOUNT.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <ssouhlal@freebsd.org>, cgroups@vger.kernel.org, penberg@kernel.org, yinghan@google.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.org, devel@openvz.org

On Tue, Mar 6, 2012 at 2:36 AM, Glauber Costa <glommer@parallels.com> wrote=
:
> On 03/04/2012 04:10 AM, Suleiman Souhlal wrote:
>>
>> Just a few lines below:
>>
>> =A0 =A0 =A0 =A0 data =3D kmalloc_node_track_caller(size, gfp_mask, node)=
;
>>
>> -- Suleiman
>
> Can't we just make sure those come from the root cgroup's slabs?
> Then we need no flag.

Do you mean make it so that all kmallocs come from the root cgroup's slabs?
We would really like to account kmallocs in general (and all the other
slab types) to the right cgroup...

That said, I'm probably going to concentrate on accounting specially
marked caches only, for now, since there seems to be a strong
opposition on accounting everything, even though I don't understand
this point of view.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
