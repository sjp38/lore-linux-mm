Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 337856B002C
	for <linux-mm@kvack.org>; Sat,  3 Mar 2012 19:10:36 -0500 (EST)
Received: by qcsu28 with SMTP id u28so1486489qcs.8
        for <linux-mm@kvack.org>; Sat, 03 Mar 2012 16:10:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F52A81A.3030408@parallels.com>
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
Date: Sat, 3 Mar 2012 16:10:34 -0800
Message-ID: <CABCjUKBP=pKgDP5RkD4BimTjoE=bQQO7NxNNAiGUfy602T4c7A@mail.gmail.com>
Subject: Re: [PATCH 04/10] memcg: Introduce __GFP_NOACCOUNT.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <ssouhlal@freebsd.org>, cgroups@vger.kernel.org, penberg@kernel.org, yinghan@google.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.org, devel@openvz.org

On Sat, Mar 3, 2012 at 3:24 PM, Glauber Costa <glommer@parallels.com> wrote=
:
> On 03/03/2012 01:38 PM, Suleiman Souhlal wrote:
>> Another possible example might be the skb data, which are just kmalloc
>> and are already accounted by your TCP accounting changes, so we might
>> not want to account them a second time.
>
>
> How so?
>
> struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int fclone, int no=
de)
> {
> =A0 =A0 =A0 =A0[ ... ]
> =A0 =A0 =A0 =A0cache =3D fclone ? skbuff_fclone_cache : skbuff_head_cache=
;
>
> =A0 =A0 =A0 =A0/* Get the HEAD */
> =A0 =A0 =A0 =A0skb =3D kmem_cache_alloc_node(cache, gfp_mask & ~__GFP_DMA=
, node);

Just a few lines below:

        data =3D kmalloc_node_track_caller(size, gfp_mask, node);

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
