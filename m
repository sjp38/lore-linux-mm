Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 35D196B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 07:34:20 -0500 (EST)
Received: by wibhj13 with SMTP id hj13so431161wib.14
        for <linux-mm@kvack.org>; Wed, 08 Feb 2012 04:34:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120208115244.GA24959@sig21.net>
References: <201202041109.53003.toralf.foerster@gmx.de>
	<201202051107.26634.toralf.foerster@gmx.de>
	<CAJd=RBCvvVgWqfSkoEaWVG=2mwKhyXarDOthHt9uwOb2fuDE9g@mail.gmail.com>
	<201202080956.18727.toralf.foerster@gmx.de>
	<20120208115244.GA24959@sig21.net>
Date: Wed, 8 Feb 2012 20:34:14 +0800
Message-ID: <CAJd=RBDbYA4xZRikGtHJvKESdiSE-B4OucZ6vQ+tHCi+hG2+aw@mail.gmail.com>
Subject: Re: swap storm since kernel 3.2.x
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Stezenbach <js@sig21.net>
Cc: =?UTF-8?Q?Toralf_F=C3=B6rster?= <toralf.foerster@gmx.de>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

2012/2/8 Johannes Stezenbach <js@sig21.net>:
> On Wed, Feb 08, 2012 at 09:56:15AM +0100, Toralf F=C3=B6rster wrote:
>>
>> From what I can tell is this:
>> If the system is under heavy I/O load and hasn't too much free RAM (git =
pull,
>> svn update and RAM consuming BOINC applications) then kernel 3.0.20 hand=
le
>> this somehow while 3.2.x run into a swap storm like.
>
> FWIW, I also saw heavy swapping with 3.2.2 with the
> CONFIG_DEBUG_OBJECTS issue reported here:
> http://lkml.org/lkml/2012/1/30/227
>
> But the thing is that even though SUnreclaim was
> huge there was still 1G MemFree and it swapped heavily
> on idle system when just switching between e.g. Firefox and gvim.
>
> Today I'm running 3.2.4 with CONFIG_DEBUG_OBJECTS disabled
> (but otherwise the same config) and it doesn't swap even
> after a fair amount of I/O:

Hah, looks not related to kswapd directly;)

>
> MemTotal: =C2=A0 =C2=A0 =C2=A0 =C2=A03940088 kB
> MemFree: =C2=A0 =C2=A0 =C2=A0 =C2=A0 1024920 kB
> Buffers: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0293328 kB
> Cached: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 447796 kB
> SwapCached: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 24 kB
> Active: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 847136 kB
> Inactive: =C2=A0 =C2=A0 =C2=A0 =C2=A0 567200 kB
> Active(anon): =C2=A0 =C2=A0 478736 kB
> Inactive(anon): =C2=A0 246744 kB
> Active(file): =C2=A0 =C2=A0 368400 kB
> Inactive(file): =C2=A0 320456 kB
> Unevictable: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 kB
> Mlocked: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 kB
> SwapTotal: =C2=A0 =C2=A0 =C2=A0 3903484 kB
> SwapFree: =C2=A0 =C2=A0 =C2=A0 =C2=A03903196 kB
> Dirty: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A016 kB
> Writeback: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 kB
> AnonPages: =C2=A0 =C2=A0 =C2=A0 =C2=A0673192 kB
> Mapped: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A040956 kB
> Shmem: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 52268 kB
> Slab: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01434188 kB
> SReclaimable: =C2=A0 =C2=A01367388 kB
> SUnreclaim: =C2=A0 =C2=A0 =C2=A0 =C2=A066800 kB
> KernelStack: =C2=A0 =C2=A0 =C2=A0 =C2=A01600 kB
> PageTables: =C2=A0 =C2=A0 =C2=A0 =C2=A0 4880 kB
> NFS_Unstable: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 kB
> Bounce: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 kB
> WritebackTmp: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 kB
> CommitLimit: =C2=A0 =C2=A0 5873528 kB
> Committed_AS: =C2=A0 =C2=A01744916 kB
> VmallocTotal: =C2=A0 34359738367 kB
> VmallocUsed: =C2=A0 =C2=A0 =C2=A0348116 kB
> VmallocChunk: =C2=A0 34359362739 kB
> DirectMap4k: =C2=A0 =C2=A0 =C2=A0 12288 kB
> DirectMap2M: =C2=A0 =C2=A0 4098048 kB
>
> =C2=A0OBJS ACTIVE =C2=A0USE OBJ SIZE =C2=A0SLABS OBJ/SLAB CACHE SIZE NAME
> =C2=A0586182 353006 =C2=A060% =C2=A0 =C2=A01.74K =C2=A032595 =C2=A0 =C2=
=A0 =C2=A0 18 =C2=A0 1043040K ext3_inode_cache
> =C2=A0289062 170979 =C2=A059% =C2=A0 =C2=A00.58K =C2=A010706 =C2=A0 =C2=
=A0 =C2=A0 27 =C2=A0 =C2=A0171296K dentry
> =C2=A0247266 107729 =C2=A043% =C2=A0 =C2=A00.42K =C2=A013737 =C2=A0 =C2=
=A0 =C2=A0 18 =C2=A0 =C2=A0109896K buffer_head
>
>
And I want to ask kswapd to do less work, the attached diff is
based on 3.2.5, mind to test it with CONFIG_DEBUG_OBJECTS enabled?

Thanks
Hillf

--- a/mm/vmscan.c	Wed Feb  8 20:10:14 2012
+++ b/mm/vmscan.c	Wed Feb  8 20:15:22 2012
@@ -2113,8 +2113,11 @@ restart:
 		 * with multiple processes reclaiming pages, the total
 		 * freeing target can get unreasonably large.
 		 */
-		if (nr_reclaimed >=3D nr_to_reclaim && priority < DEF_PRIORITY)
+		if (nr_reclaimed >=3D nr_to_reclaim) {
+			nr_to_reclaim =3D 0;
 			break;
+		}
+		nr_to_reclaim -=3D nr_reclaimed;
 	}
 	blk_finish_plug(&plug);
 	sc->nr_reclaimed +=3D nr_reclaimed;
@@ -2683,12 +2686,12 @@ static unsigned long balance_pgdat(pg_da
 		 * we want to put equal scanning pressure on each zone.
 		 */
 		.nr_to_reclaim =3D ULONG_MAX,
-		.order =3D order,
 		.target_mem_cgroup =3D NULL,
 	};
 	struct shrink_control shrink =3D {
 		.gfp_mask =3D sc.gfp_mask,
 	};
+	sc.order =3D order =3D 0;
 loop_again:
 	total_scanned =3D 0;
 	sc.nr_reclaimed =3D 0;
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
