Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 79AEA6B025F
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 09:33:21 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id l4so6095981wre.10
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 06:33:21 -0800 (PST)
Received: from smtp-out6.electric.net (smtp-out6.electric.net. [192.162.217.181])
        by mx.google.com with ESMTPS id x56si897499edm.293.2017.12.08.06.33.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Dec 2017 06:33:19 -0800 (PST)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 0/2] mm: introduce MAP_FIXED_SAFE
Date: Fri, 8 Dec 2017 14:33:35 +0000
Message-ID: <0b0bd6862e3a47728c8f658c8a6b3dea@AcuMS.aculab.com>
References: <20171129144219.22867-1-mhocko@kernel.org>
 <CAGXu5jLa=b2HhjWXXTQunaZuz11qUhm5aNXHpS26jVqb=G-gfw@mail.gmail.com>
 <20171130065835.dbw4ajh5q5whikhf@dhcp22.suse.cz> <20171201152640.GA3765@rei>
 <87wp20e9wf.fsf@concordia.ellerman.id.au>
 <20171206045433.GQ26021@bombadil.infradead.org>
 <20171206070355.GA32044@bombadil.infradead.org>
 <87bmjbks4c.fsf@concordia.ellerman.id.au>
 <CAGXu5jLWRQn6EaXEEvdvXr+4gbiJawwp1EaLMfYisHVfMiqgSA@mail.gmail.com>
 <20171207195727.GA26792@bombadil.infradead.org>
 <87shclh3zc.fsf@concordia.ellerman.id.au>
In-Reply-To: <87shclh3zc.fsf@concordia.ellerman.id.au>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michael Ellerman' <mpe@ellerman.id.au>, Matthew Wilcox <willy@infradead.org>, Kees Cook <keescook@chromium.org>
Cc: Cyril Hrubis <chrubis@suse.cz>, Michal Hocko <mhocko@kernel.org>, Linux
 API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, John
 Hubbard <jhubbard@nvidia.com>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Pavel Machek <pavel@ucw.cz>

From: Michael Ellerman
> Sent: 08 December 2017 11:08
...
> If we had a time machine, the right set of flags would be:
>=20
>   - MAP_FIXED:   don't treat addr as a hint, fail if addr is not free
>   - MAP_REPLACE: replace an existing mapping (or force or clobber)
>=20
> But the two were conflated for some reason in the current MAP_FIXED.

Possibly because the original use was loading overlays?

> Given we can't go back and fix it, the closest we can get is to add a
> variant of MAP_FIXED which subtracts the "REPLACE" semantic.
>=20
> ie: MAP_FIXED_NOREPLACE

Much better than _SAFE - which is always bad because it is usually
one 'safe' for one specific use case.

	David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
