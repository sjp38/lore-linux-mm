Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id C42846B0031
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 04:18:08 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id a1so223544wgh.28
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 01:18:08 -0800 (PST)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id ap4si916295wjc.64.2014.01.09.01.18.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 01:18:08 -0800 (PST)
Received: by mail-wi0-f173.google.com with SMTP id hn9so6634505wib.0
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 01:18:08 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 5/7] mm/page_alloc: separate interface to set/get migratetype of freepage
In-Reply-To: <1389251087-10224-6-git-send-email-iamjoonsoo.kim@lge.com>
References: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com> <1389251087-10224-6-git-send-email-iamjoonsoo.kim@lge.com>
Date: Thu, 09 Jan 2014 10:18:00 +0100
Message-ID: <xa1tbnzlbjjr.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jiang Liu <jiang.liu@huawei.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Andi Kleen <ak@linux.intel.com>, Wei Yongjun <yongjun_wei@trendmicro.com.cn>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 09 2014, Joonsoo Kim wrote:
> Currently, we use (set/get)_freepage_migratetype in two use cases.
> One is to know the buddy list where this page will be linked and
> the other is to know the buddy list where this page is linked now.
>
> But, we should deal these two use cases differently, because information
> isn't sufficient for the second use case and properly setting this
> information needs some overhead. Whenever the page is merged or split
> in buddy, this information isn't properly re-assigned and it may not
> have enough information for the second use case.
>
> This patch just separates interface, so there is no functional change.
> Following patch will do further steps about this issue.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

I think this patch would be smaller if it was pushed earlier in the
patchset.

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJSzmlIAAoJECBgQBJQdR/0aFAP+waDevUQpa9xhmLPbYlXrCpa
LO3GprL2KYWtpEnjGAkGmI1ywnsbukNNpXg/q9n1xY/fr7SYQlys9TFnPsydRFq7
R5K3M07ITUEeEl65h269aU86odK1iH246ch3fwjPOrPOz6hmZkwiHUos6dDWE4SN
Oe8/FzbhLHVXpKrSrnc9rSdArZfUbjSmPx3Np/32WCWTE9nEQxT5G1tLrRMhd2nh
QAyKS93Z4YDwFGRnniibbfC3lns7lRbSAtUUS+SBNXaqQpa8jPA7rklsuDR8YXw1
YLY88ojn7pyW8cZsNn93oe9m9O850EbTJOHzVZIgJeRU04pOWRmKF7WYQSq8ZSvo
MvuRBNXz05huYVwyUKvCUAyNmoDhobOSEFE2Go3vaYcA7dhPYMm00VzIdJI1u/w0
63zwaWfVUcqFvnnsOZMTHrJlb/U0Cvv8pBUJcSW8uPL3VNl8P5v4jKXaY7gWMEmq
g8h6Pz8Bv3S9qAnO9YDRaT20jcQjVVRnrxya/ovgwhU8l+/qbWMkCQvcMRXXgY7G
+oBXZwmRYcFGIdrMox2GbtlrQWFj9C8/VrzlqbJNvAOU76t9PJ/429JENp7hjidL
U9TngSMevAAOgbvZzIchVKLKBLXIiCb+RIf87JEYIdLT3sspRBZwgPiBAn/PYXTL
kdwG+bGk3CGEGcrT8/Tp
=19u7
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
