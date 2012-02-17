Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id B5E856B007E
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 04:04:19 -0500 (EST)
From: Venu Byravarasu <vbyravarasu@nvidia.com>
Date: Fri, 17 Feb 2012 14:34:13 +0530
Subject: RE: [PATCH] mm: mmap() sometimes succeeds even if the region to map
 is invalid.
Message-ID: <D958900912E20642BCBC71664EFECE3E6DD198A7AE@BGMAIL02.nvidia.com>
References: <4F3E1319.6050304@jp.fujitsu.com>
In-Reply-To: <4F3E1319.6050304@jp.fujitsu.com>
MIME-Version: 1.0
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naotaka Hamaguchi <n.hamaguchi@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>

> The detail of these problems is as follows:

> 1. mmap() succeeds even if "offset" argument is a negative value, althoug=
h
>    it should return EINVAL in such case.

> In such case, it is actually regarded as big positive value
> because the type of "off" is "unsigned long" in the kernel.
> For example, off=3D-4096 (-0x1000) is regarded as
> off =3D 0xfffffffffffff000 (x86_64) and as off =3D 0xfffff000 (x86).
> It results in mapping too big offset region.

It is not true always.

Considering your example, say if page size is 4k, then PAGE_MASK =3D 0xFFF
hence (off & ~PAGE_MASK) will be true and " -EINVAL" will be returned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
