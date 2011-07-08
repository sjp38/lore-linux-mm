Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id C16B39000C2
	for <linux-mm@kvack.org>; Fri,  8 Jul 2011 01:14:13 -0400 (EDT)
Received: by qwa26 with SMTP id 26so1092121qwa.14
        for <linux-mm@kvack.org>; Thu, 07 Jul 2011 22:14:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGtzr3fm2=UJFRo2xSYhst0P4jCMT-EPjyPi3=icCrMtW0ij8w@mail.gmail.com>
References: <CAGtzr3fm2=UJFRo2xSYhst0P4jCMT-EPjyPi3=icCrMtW0ij8w@mail.gmail.com>
Date: Fri, 8 Jul 2011 14:14:09 +0900
Message-ID: <CAEwNFnB8VXkTiMzJewtd7rSZ8keqkboNz-BBjw_UudquvsrK1A@mail.gmail.com>
Subject: Re: NULL poniter dereference in isolate_lru_pages 2.6.39.1
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Pearson <kermit4@gmail.com>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>

On Fri, Jul 8, 2011 at 12:53 AM, Chris Pearson <kermit4@gmail.com> wrote:
> see attached screenshots
>
> NULL pointer dereference at 8
>
> isolate_lru_pages
> shrink_inactive_list
> __lookup_tag
> shrink_zone
> shrink_slab
> kswapd
> zone_reclaim
>
> These are from 3 different servers in the past week since we upgraded
> a few hundred of them to 2.6.39.1. =C2=A0 =C2=A0They're under a steady fe=
w MB/s
> of net and disk I/O load.
>
> We have the following /proc adjustments:
>
> kernel.shmmax =3D 135217728
> fs.file-max =3D 65535
> vm.swappiness =3D 10
> vm.min_free_kbytes =3D 65535
>

I didn't have see such BUG until now.
Could you tell me which point is isolate_lru_pages + 0x225?
You can get it with addr2line -e vmlinux -i ffffffff8108ed15 or gdb.

The culprit I think is page_count.
A month ago, Andrea pointed out and sent the patch but it seems it
isn't stable tree.

Could you test below patch?
https://patchwork.kernel.org/patch/857442/



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
