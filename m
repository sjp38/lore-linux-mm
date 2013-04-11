Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 56FFE6B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 13:18:12 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <399a2a41-fa4d-41d9-80aa-5b4c51fee68e@default>
Date: Thu, 11 Apr 2013 10:17:56 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 00/10] staging: zcache/ramster: fix and ramster/debugfs
 improvement
References: <<1365553560-32258-1-git-send-email-liwanp@linux.vnet.ibm.com>>
In-Reply-To: <<1365553560-32258-1-git-send-email-liwanp@linux.vnet.ibm.com>>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>

> From: Wanpeng Li [mailto:liwanp@linux.vnet.ibm.com]
> Sent: Tuesday, April 09, 2013 6:26 PM
> To: Greg Kroah-Hartman
> Cc: Dan Magenheimer; Seth Jennings; Konrad Rzeszutek Wilk; Minchan Kim; l=
inux-mm@kvack.org; linux-
> kernel@vger.kernel.org; Andrew Morton; Bob Liu; Wanpeng Li
> Subject: [PATCH 00/10] staging: zcache/ramster: fix and ramster/debugfs i=
mprovement
>=20
> Fix bugs in zcache and rips out the debug counters out of ramster.c and
> sticks them in a debug.c file. Introduce accessory functions for counters
> increase/decrease, they are available when config RAMSTER_DEBUG, otherwis=
e
> they are empty non-debug functions. Using an array to initialize/use debu=
gfs
> attributes to make them neater. Dan Magenheimer confirm these works
> are needed. http://marc.info/?l=3Dlinux-mm&m=3D136535713106882&w=3D2
>=20
> Patch 1~2 fix bugs in zcache
>=20
> Patch 3~8 rips out the debug counters out of ramster.c and sticks them
> =09=09  in a debug.c file
>=20
> Patch 9 fix coding style issue introduced in zcache2 cleanups
>         (s/int/bool + debugfs movement) patchset
>=20
> Patch 10 add how-to for ramster

Note my preference to not apply patch 2of10 (which GregKH may choose
to override), but for all, please add my:
Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
