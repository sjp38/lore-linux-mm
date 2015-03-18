Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2DBAB6B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 11:14:20 -0400 (EDT)
Received: by lagg8 with SMTP id g8so38705569lag.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 08:14:19 -0700 (PDT)
Received: from shrek.krogh.cc (188-178-198-210-static.dk.customer.tdc.net. [188.178.198.210])
        by mx.google.com with ESMTPS id p8si13098137laf.145.2015.03.18.08.14.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 08:14:18 -0700 (PDT)
References: <52ec58f434865829c37337624d124981.squirrel@shrek.krogh.cc> <CABYiri81_RAtJizfpOdNPc6m9_Q2u0O35NX0ZhO1cxFpm866HQ@mail.gmail.com> <a0dcd8d7307e313474d4d721c76bb5a9.squirrel@shrek.krogh.cc> <CABYiri9BcgNEYD5C4qGf=3q6a=d549Rp9rXD7BAo8NkVDAPOqA@mail.gmail.com> <5509889C.2080602@suse.cz>
Mime-Version: 1.0 (1.0)
In-Reply-To: <5509889C.2080602@suse.cz>
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Message-Id: <0C41F6DA-DECD-48AD-90AD-DAF964950EB9@krogh.cc>
From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: High system load and 3TB of memory.
Date: Wed, 18 Mar 2015 16:14:05 +0100
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrey Korolyov <andrey@xdel.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christian Marie <christian@ponies.io>


> On 18/03/2015, at 15.15, Vlastimil Babka <vbabka@suse.cz>
> Right, it would be great if you could try it with 3.18+ kernel and possibl=
y Joonsoo's patch from
> http://marc.info/?l=3Dlinux-mm&m=3D141774145601066
>=20

Thanks, we will do that.

We actually upgraded to 3.18.9 monday (together whith moving the database fr=
om postgresql 9.2 to 9.3) and we havent seen the problem since.

Sysload is sitting around 8-10%

But we will test

Jesper


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
