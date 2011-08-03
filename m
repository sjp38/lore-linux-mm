Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id E8C6C6B0169
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 02:45:52 -0400 (EDT)
Received: by vwm42 with SMTP id 42so400317vwm.14
        for <linux-mm@kvack.org>; Tue, 02 Aug 2011 23:45:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110802142459.GF10436@suse.de>
References: <CAJn8CcE20-co4xNOD8c+0jMeABrc1mjmGzju3xT34QwHHHFsUA@mail.gmail.com>
	<CAJn8CcG-pNbg88+HLB=tRr26_R+A0RxZEWsJQg4iGe4eY2noXA@mail.gmail.com>
	<20110802142459.GF10436@suse.de>
Date: Wed, 3 Aug 2011 14:45:51 +0800
Message-ID: <CAJn8CcF83cu3pYeVUH+F4Pao8jrnze-EVy_b-DnSUtN6HN_r2g@mail.gmail.com>
Subject: Re: kernel BUG at mm/vmscan.c:1114
From: Xiaotian Feng <xtfeng@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Aug 2, 2011 at 10:24 PM, Mel Gorman <mgorman@suse.de> wrote:
> On Tue, Aug 02, 2011 at 03:09:57PM +0800, Xiaotian Feng wrote:
>> Hi,
>> =C2=A0 =C2=A0I'm hitting the kernel BUG at mm/vmscan.c:1114 twice, each =
time I
>> was trying to build my kernel. The photo of crash screen and my config
>> is attached. Thanks.
>> Regards
>> Xiaotian
>
> I am obviously blind because in 3.0, I cannot see what BUG is at
> mm/vmscan.c:1114 :(. I see
>
> 1109: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> 1110: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0* If we don't have enough swap space, reclaiming of
> 1111: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0* anon page which don't already have a swap slot is
> 1112: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0* pointless.
> 1113: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0*/
> 1114: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (=
nr_swap_pages <=3D 0 && PageAnon(cursor_page) &&
> 1115: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 !PageSwapCache(cursor_page))
> 1116: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 break;
> 1117:
> 1118: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (=
__isolate_lru_page(cursor_page, mode, file) =3D=3D 0) {
> 1119: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 list_move(&cursor_page->lru, dst);
> 1120: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_del_lru(cursor_page);
>
> Is this 3.0 vanilla or are there some other patches applied?

No, I'm using fresh cloned upstream kernel, without any changes. Thanks.

>
> --
> Mel Gorman
> SUSE Labs
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
