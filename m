Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 7C0A26B00EB
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 15:37:00 -0400 (EDT)
Subject: Re: [PATCH -mm] do_migrate_pages() calls migrate_to_node() even if task is already on a correct node
In-Reply-To: Your message of "Thu, 22 Mar 2012 15:07:00 -0400."
             <4F6B7854.1040203@redhat.com>
From: Valdis.Kletnieks@vt.edu
References: <4F6B6BFF.1020701@redhat.com> <4F6B7358.60800@gmail.com> <alpine.DEB.2.00.1203221348470.25011@router.home>
            <4F6B7854.1040203@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1332445016_39840P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Thu, 22 Mar 2012 15:36:56 -0400
Message-ID: <40300.1332445016@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lwoodman@redhat.com
Cc: Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Motohiro Kosaki <mkosaki@redhat.com>

--==_Exmh_1332445016_39840P
Content-Type: text/plain; charset=us-ascii

On Thu, 22 Mar 2012 15:07:00 -0400, Larry Woodman said:

> So to be clear on this, in that case the intention would be move 3 to 4,
> 4 to 5 and 5 to 6
> to keep the node ordering the same?

Would it make more sense to do 5->6, 4->5, 3->4?  If we move stuff
from 3 to 4 before clearing the old 4 stuff out, it might get crowded?


--==_Exmh_1332445016_39840P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBT2t/VwdmEQWDXROgAQIkgg//WSjenDA84KouiK00Bf7PdzfwvRLox3kL
3IN/CMMaPLbOIjjO1Uy8NpCJAgNRTrR40mpzAY3zLs3y7Ir6bYb9W2UtG72Xu/Io
XdsTkXQQ4BQvBsOe21YSqKVORtziXLw9LhlDpfJRPog+ocDjIrlK5twCG4VpSisf
Vl1RwbEkRMFlEJSHCbzwbzlaMNgG9CAdBxD+hnFsAgTgk+bXW37zEhw+v07tWtVU
Foy1Cpa/QhHyxuuQ9MvMALu8jO8g4fzhUB10JRbLUa7e3AKZ9G/Sp0pBGIDpgMkd
40HNg0Xf3Yv0PBRBtAjQSojiu+iFwohsA3ian1aPHZVR7Zp8pFi3RC1QVZcpI+lq
3WAi5zvM9oeVnKxUTy1ya1w9cG8vf8XFgI1WOomtVfDIc0Ndd6yCvWU7DfLknkTb
pDN1DdH0MtGZtym64C4DbRdp4Vy9cjcYOD9OcFN1+ZGx/pD3ggzUw9bPZcH5/AFh
Hqlhrr+7bf+fTsdoIqspVXhs+NlrRQegQTyJjivOitTKcehrG6WcQYta8q51uLF7
Jl6ms8dlPJWrLiXZSCSdfEMxf0AQj/yoyzSB7rtixPQyOPLrKGs6nkZhpjmjdO/D
v3edqqnCHcoVyEtJS83UN3A6qU5a0qg5pM3npB2gHjP4uQp6HChWBIz+rMV/gCy0
lDzYDAe23OE=
=xLes
-----END PGP SIGNATURE-----

--==_Exmh_1332445016_39840P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
