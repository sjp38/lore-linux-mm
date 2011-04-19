Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AF5788D0040
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 13:55:57 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p3JHtnOK025343
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 10:55:49 -0700
Received: from qwb8 (qwb8.prod.google.com [10.241.193.72])
	by hpaq2.eem.corp.google.com with ESMTP id p3JHtH2N027750
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 10:55:45 -0700
Received: by qwb8 with SMTP id 8so5862239qwb.11
        for <linux-mm@kvack.org>; Tue, 19 Apr 2011 10:55:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1303235496-3060-1-git-send-email-yinghan@google.com>
References: <1303235496-3060-1-git-send-email-yinghan@google.com>
Date: Tue, 19 Apr 2011 10:55:45 -0700
Message-ID: <BANLkTikyXvDoT74imck84PifzJsmoZ=hpQ@mail.gmail.com>
Subject: Re: [PATCH 0/3] pass the scan_control into shrinkers
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=002354470674a79d4f04a1493772
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

--002354470674a79d4f04a1493772
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Apr 19, 2011 at 10:51 AM, Ying Han <yinghan@google.com> wrote:

> This patch changes the shrink_slab and shrinker APIs by consolidating
> existing
> parameters into scan_control struct. This simplifies any further attempts
> to
> pass extra info to the shrinker. Instead of modifying all the shrinker
> files
> each time, we just need to extend the scan_control struct.
>
> This patch is based on mmotm-2011-03-31-14-48.
>
> Ying Han (3):
>  move scan_control definition to header file
>  change the shrink_slab by passing scan_control.
>  change shrinker API by passing scan_control struct
>
>  arch/x86/kvm/mmu.c                   |    3 +-
>  drivers/gpu/drm/i915/i915_gem.c      |    5 +-
>  drivers/gpu/drm/ttm/ttm_page_alloc.c |    1 +
>  drivers/staging/zcache/zcache.c      |    5 ++-
>  fs/dcache.c                          |    8 ++-
>  fs/drop_caches.c                     |    7 ++-
>  fs/gfs2/glock.c                      |    5 ++-
>  fs/inode.c                           |    6 ++-
>  fs/mbcache.c                         |   11 ++--
>  fs/nfs/dir.c                         |    5 ++-
>  fs/nfs/internal.h                    |    2 +-
>  fs/quota/dquot.c                     |    6 ++-
>  fs/xfs/linux-2.6/xfs_buf.c           |    4 +-
>  fs/xfs/linux-2.6/xfs_sync.c          |    5 +-
>  fs/xfs/quota/xfs_qm.c                |    5 +-
>  include/linux/mm.h                   |   16 +++---
>  include/linux/swap.h                 |   64 ++++++++++++++++++++++++++
>  mm/vmscan.c                          |   84
> +++++----------------------------
>  net/sunrpc/auth.c                    |    5 ++-
>  19 files changed, 143 insertions(+), 104 deletions(-)
>
> --
> 1.7.3.1
>
>

--002354470674a79d4f04a1493772
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, Apr 19, 2011 at 10:51 AM, Ying H=
an <span dir=3D"ltr">&lt;<a href=3D"mailto:yinghan@google.com">yinghan@goog=
le.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"=
margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
This patch changes the shrink_slab and shrinker APIs by consolidating exist=
ing<br>
parameters into scan_control struct. This simplifies any further attempts t=
o<br>
pass extra info to the shrinker. Instead of modifying all the shrinker file=
s<br>
each time, we just need to extend the scan_control struct.<br>
<br>
This patch is based on mmotm-2011-03-31-14-48.<br>
<br>
Ying Han (3):<br>
 =A0move scan_control definition to header file<br>
 =A0change the shrink_slab by passing scan_control.<br>
 =A0change shrinker API by passing scan_control struct<br>
<br>
=A0arch/x86/kvm/mmu.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +-<br>
=A0drivers/gpu/drm/i915/i915_gem.c =A0 =A0 =A0| =A0 =A05 +-<br>
=A0drivers/gpu/drm/ttm/ttm_page_alloc.c | =A0 =A01 +<br>
=A0drivers/staging/zcache/zcache.c =A0 =A0 =A0| =A0 =A05 ++-<br>
=A0fs/dcache.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0=
8 ++-<br>
=A0fs/drop_caches.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A07 ++-<=
br>
=A0fs/gfs2/glock.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A05 ++=
-<br>
=A0fs/inode.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
6 ++-<br>
=A0fs/mbcache.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 11 ++=
--<br>
=A0fs/nfs/dir.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A05 =
++-<br>
=A0fs/nfs/internal.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-<b=
r>
=A0fs/quota/dquot.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A06 ++-<=
br>
=A0fs/xfs/linux-2.6/xfs_buf.c =A0 =A0 =A0 =A0 =A0 | =A0 =A04 +-<br>
=A0fs/xfs/linux-2.6/xfs_sync.c =A0 =A0 =A0 =A0 =A0| =A0 =A05 +-<br>
=A0fs/xfs/quota/xfs_qm.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A05 +-<br>
=A0include/linux/mm.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 16 +++---<b=
r>
=A0include/linux/swap.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 64 ++++++++++=
++++++++++++++++<br>
=A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 84 =
+++++----------------------------<br>
=A0net/sunrpc/auth.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A05 ++-<=
br>
=A019 files changed, 143 insertions(+), 104 deletions(-)<br>
<font color=3D"#888888"><br>
--<br>
1.7.3.1<br>
<br>
</font></blockquote></div><br>

--002354470674a79d4f04a1493772--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
