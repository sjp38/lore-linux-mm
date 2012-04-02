Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 2D3E26B0044
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 08:52:13 -0400 (EDT)
From: "Luca Porzio (lporzio)" <lporzio@micron.com>
Subject: RE: swap on eMMC and other flash
Date: Mon, 2 Apr 2012 12:52:04 +0000
Message-ID: <26E7A31274623843B0E8CF86148BFE326FB55F8B@NTXAVZMBX04.azit.micron.com>
References: <201203301744.16762.arnd@arndb.de>
 <201203301850.22784.arnd@arndb.de>
 <alpine.LSU.2.00.1203311230490.10965@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1203311230490.10965@eggly.anvils>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Arnd Bergmann <arnd@arndb.de>
Cc: Rik van Riel <riel@redhat.com>, "linaro-kernel@lists.linaro.org" <linaro-kernel@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Alex Lemberg <alex.lemberg@sandisk.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Saugata Das <saugata.das@linaro.org>, Venkatraman S <venkat@linaro.org>, Yejin Moon <yejin.moon@samsung.com>, Hyojin Jeong <syr.jeong@samsung.com>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, "kernel-team@android.com" <kernel-team@android.com>

Hugh,

Great topics. As per one of Rik original points:

> 4) skip writeout of zero-filled pages - this can be a big help
>     for KVM virtual machines running Windows, since Windows zeroes
>     out free pages;   simply discarding a zero-filled page is not
>     at all simple in the current VM, where we would have to iterate
>     over all the ptes to free the swap entry before being able to
>     free the swap cache page (I am not sure how that locking would
>     even work)
>=20
>     with the extra layer of indirection, the locking for this scheme
>     can be trivial - either the faulting process gets the old page,
>     or it gets a new one, either way it'll be zero filled
>=20

Since it's KVMs realm here, can't KSM simply solve the zero-filled pages pr=
oblem avoiding unnecessary burden for the Swap subsystem?

Cheers,=20
   Luca

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
