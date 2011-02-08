Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F1B278D0039
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 18:56:09 -0500 (EST)
Received: by iwc10 with SMTP id 10so6456883iwc.14
        for <linux-mm@kvack.org>; Tue, 08 Feb 2011 15:56:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <0d1aa13e-be1f-4e21-adf2-f0162c67ede3@default>
References: <AANLkTi=CEXiOdqPZgQZmQwatHqZ_nsnmnVhwpdt=7q3f@mail.gmail.com>
	<0d1aa13e-be1f-4e21-adf2-f0162c67ede3@default>
Date: Wed, 9 Feb 2011 08:56:07 +0900
Message-ID: <AANLkTimm8o6FnDon=eMTepDaoViU9tjteAYE9kmJhMsx@mail.gmail.com>
Subject: Re: [PATCH V2 2/3] drivers/staging: zcache: host services and PAM services
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: gregkh@suse.de, Chris Mason <chris.mason@oracle.com>, akpm@linux-foundation.org, torvalds@linux-foundation.org, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, riel@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, sfr@canb.auug.org.au, wfg@mail.ustc.edu.cn, tytso@mit.edu, viro@zeniv.linux.org.uk, hughd@google.com, hannes@cmpxchg.org

On Wed, Feb 9, 2011 at 8:27 AM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
> Hi Minchan --
>
>> First of all, thanks for endless effort.
>
> Sometimes it does seem endless ;-)
>
>> I didn't look at code entirely but it seems this series includes
>> frontswap.
>
> The "new zcache" optionally depends on frontswap, but frontswap is
> a separate patchset. =C2=A0If the frontswap patchset is present
> and configured, zcache will use it to dynamically compress swap pages.
> If frontswap is not present or not configured, zcache will only
> use cleancache to dynamically compress clean page cache pages.
> For best results, both frontswap and cleancache should be enabled.
> (and see the link in PATCH V2 0/3 for a monolithic patch against
> 2.6.37 that enabled both).
>
>> Finally frontswap is to replace zram?
>
> Nitin and I have agreed that, for now, both frontswap and zram
> should continue to exist. =C2=A0They have similar functionality but
> different use models. =C2=A0Over time we will see if they can be merged.
>
> Nitin and I agreed offlist that the following summarizes the
> differences between zram and frontswap:
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> Zram uses an asynchronous model (e.g. uses the block I/O subsystem)
> and requires a device to be explicitly created. =C2=A0When used for
> swap, mkswap creates a fixed-size swap device (usually with higher
> priority than any disk-based swap device) and zram is filled
> until it is full, at which point other lower-priority (disk-based)
> swap devices are then used. =C2=A0So zram is well-suited for a fixed-
> size-RAM machine with a known workload where an administrator
> can pre-configure a zram device to improve RAM efficiency during
> peak memory load.
>
> Frontswap uses a synchronous model, circumventing the block I/O
> subsystem. =C2=A0The frontswap "device" is completely dynamic in size,
> e.g. frontswap is queried for every individual page-to-be-swapped
> and, if rejected, the page is swapped to the "real" swap device.
> So frontswap is well-suited for highly dynamic conditions where
> workload is unpredictable and/or RAM size may "vary" due to
> circumstances not entirely within the kernel's control.
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> Does that make sense?

Thanks for the quick reply.
As I read your comment, I can't find the benefit of zram compared to fronts=
wap.

1. asynchronous model
2. usability
3. adaptive dynamic ram size

If I consider your statement, with 2, 3, zram isn't better than
fronswap, I think.
1 on zram may be good than frontswap but I doubt how much we have a
big benefit on async operation in ramdisk model.

If we have a big overhead of block stuff in such a model, couldn't we
remove the overhead generally?

What I can think of benefit is that zram export interface to block
device so someone can use compressed block device.
Block device interface exporting is enough to live zram in there?

Maybe I miss something of zram's benefits.
At least, I can't convince why zram and frontswap should coexist.
AFAIK, Nitin and you discussed it many times long time ago but I
didn't follow up it.  Sorry if I am missing something.

Thanks.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
