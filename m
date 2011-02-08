Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3357C8D0039
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 17:48:28 -0500 (EST)
Received: by iwc10 with SMTP id 10so6412379iwc.14
        for <linux-mm@kvack.org>; Tue, 08 Feb 2011 14:48:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110207032608.GA27453@ca-server1.us.oracle.com>
References: <20110207032608.GA27453@ca-server1.us.oracle.com>
Date: Wed, 9 Feb 2011 07:48:22 +0900
Message-ID: <AANLkTi=CEXiOdqPZgQZmQwatHqZ_nsnmnVhwpdt=7q3f@mail.gmail.com>
Subject: Re: [PATCH V2 2/3] drivers/staging: zcache: host services and PAM services
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: gregkh@suse.de, chris.mason@oracle.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, kurt.hackel@oracle.com, npiggin@kernel.dk, riel@redhat.com, konrad.wilk@oracle.com, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, sfr@canb.auug.org.au, wfg@mail.ustc.edu.cn, tytso@mit.edu, viro@zeniv.linux.org.uk, hughd@google.com, hannes@cmpxchg.org

On Mon, Feb 7, 2011 at 12:26 PM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
> [PATCH V2 2/3] drivers/staging: zcache: host services and PAM services
>
> Zcache provides host services (memory allocation) for tmem,
> a "shim" to interface cleancache and frontswap to tmem, and
> two different page-addressable memory implemenations using
> lzo1x compression. =C2=A0The first, "compression buddies" ("zbud")
> compresses pairs of pages and supplies a shrinker interface
> that allows entire pages to be reclaimed. =C2=A0The second is
> a shim to xvMalloc which is more space-efficient but
> less receptive to page reclamation. =C2=A0The first is used
> for ephemeral pools and the second for persistent pools.
> All ephemeral pools share the same memory, that is, even
> pages from different pools can share the same page.
>
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> Signed-off-by: Nitin Gupta <ngupta@vflare.org>

Hi Dan,
First of all, thanks for endless effort.

I didn't look at code entirely but it seems this series includes frontswap.
Finally frontswap is to replace zram?

If it is right, how about approaching one by one for easy review and mergin=
g?
I mean firstly we replace zram into frontswap and tmem and then zcache.
Regardless of my suggestion, I will look at the this series in my spare tim=
e.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
