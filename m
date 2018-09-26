Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id D98A78E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 11:24:45 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id p192-v6so29771144qke.13
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 08:24:45 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w7-v6sor1190846qvh.152.2018.09.26.08.24.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Sep 2018 08:24:44 -0700 (PDT)
Date: Wed, 26 Sep 2018 11:25:23 -0400
From: Konstantin Ryabitsev <konstantin@linuxfoundation.org>
Subject: Re: linux-mm@ archive on lore.kernel.org (Was: [PATCH 0/2] thp
 nodereclaim fixes)
Message-ID: <20180926152523.GA8154@chatter>
References: <20180925120326.24392-1-mhocko@kernel.org>
 <20180926130850.vk6y6zxppn7bkovk@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="J2SCkAp4GZ/dPZZf"
Content-Disposition: inline
In-Reply-To: <20180926130850.vk6y6zxppn7bkovk@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>


--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 26, 2018 at 04:08:50PM +0300, Kirill A. Shutemov wrote:
>On Tue, Sep 25, 2018 at 02:03:24PM +0200, Michal Hocko wrote:
>> Thoughts, alternative patches?
>>
>> [1] http://lkml.kernel.org/r/20180820032204.9591-1-aarcange@redhat.com
>> [2] http://lkml.kernel.org/r/20180830064732.GA2656@dhcp22.suse.cz
>> [3] http://lkml.kernel.org/r/20180820032640.9896-2-aarcange@redhat.com
>
>All these links are broken. lore.kernel.org doesn't have linux-mm@ archive.
>
>Can we get it added?

Adding linux-mm to lore.kernel.org certainly should happen, but it will=20
not fix the above problem, because lkml.kernel.org/r/<foo> links only=20
work for messages on LKML, not for all messages passing through vger=20
lists (hence the word "lkml" in the name).

Once linux-mm is added, you should link to those discussions using=20
lore.kernel.org/linux-mm/<msgid> links.

-K

--J2SCkAp4GZ/dPZZf
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYIAB0WIQR2vl2yUnHhSB5njDW2xBzjVmSZbAUCW6uk4wAKCRC2xBzjVmSZ
bJwRAQCMjR606Nwvm/8ppqVhjAIW0Nak0uvZWnyjcUZqt8xLmgD9HDeVOPWIE77M
1X7L6stT5sKJjgA6RIG3buA8XFQlvAY=
=mlkK
-----END PGP SIGNATURE-----

--J2SCkAp4GZ/dPZZf--
