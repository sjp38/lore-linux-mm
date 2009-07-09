Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E29116B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 06:06:42 -0400 (EDT)
Received: by gxk3 with SMTP id 3so74883gxk.14
        for <linux-mm@kvack.org>; Thu, 09 Jul 2009 03:22:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090709171247.23C6.A69D9226@jp.fujitsu.com>
References: <20090709165820.23B7.A69D9226@jp.fujitsu.com>
	 <20090709171247.23C6.A69D9226@jp.fujitsu.com>
Date: Thu, 9 Jul 2009 19:22:26 +0900
Message-ID: <28c262360907090322u55ba7a1blea49c6063bbee528@mail.gmail.com>
Subject: Re: [PATCH 4/5] add isolate pages vmstat
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 9, 2009 at 5:14 PM, KOSAKI
Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
> ChangeLog
> =C2=A0Since v4
> =C2=A0 - Changed displaing order in show_free_areas() (as Wu's suggested)
> =C2=A0Since v3
> =C2=A0 - Fixed misaccount page bug when lumby reclaim occur
> =C2=A0Since v2
> =C2=A0 - Separated IsolateLRU field to Isolated(anon) and Isolated(file)
> =C2=A0Since v1
> =C2=A0 - Renamed IsolatePages to IsolatedLRU
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> Subject: [PATCH] add isolate pages vmstat
>
> If the system have plenty threads or processes, concurrent reclaim can
> isolate very much pages.
> Unfortunately, current /proc/meminfo and OOM log can't show it.
>
> This patch provide the way of showing this information.
>
>
> reproduce way
> -----------------------
> % ./hackbench 140 process 1000
> =C2=A0 =3D> couse OOM
>
> active_anon:146 inactive_anon:0 isolated_anon:49245
> =C2=A0active_file:41 inactive_file:0 isolated_file:113
> =C2=A0unevictable:0
> =C2=A0dirty:0 writeback:0 buffer:49 unstable:0
> =C2=A0free:184 slab_reclaimable:276 slab_unreclaimable:5492
> =C2=A0mapped:87 pagetables:28239 bounce:0
>
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Acked-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
