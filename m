Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7C0586B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 03:12:17 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y13so4150613pdi.27
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 00:12:17 -0700 (PDT)
Received: from relay1.mentorg.com (relay1.mentorg.com. [192.94.38.131])
        by mx.google.com with ESMTPS id gj4si9931518pbb.112.2014.06.16.00.12.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 00:12:16 -0700 (PDT)
From: Thomas Schwinge <thomas@codesourcery.com>
Subject: Re: radeon: screen garbled after page allocator change, was: Re: [patch v2 3/3] mm: page_alloc: fair zone allocator policy
In-Reply-To: <87ppk1q3iq.fsf@schwinge.name>
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org> <1375457846-21521-4-git-send-email-hannes@cmpxchg.org> <87r45fajun.fsf@schwinge.name> <20140424133722.GD4107@cmpxchg.org> <20140427033110.GA15091@gmail.com> <20140427195527.GC9315@gmail.com> <87ppk1q3iq.fsf@schwinge.name>
Date: Mon, 16 Jun 2014 09:11:52 +0200
Message-ID: <87vbs1z5tz.fsf@schwinge.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-="; micalg=pgp-sha1;
	protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@surriel.com>, Andrea Arcangeli <aarcange@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Alex Deucher <alexander.deucher@amd.com>, Christian =?utf-8?Q?K=C3=B6nig?= <christian.koenig@amd.com>, dri-devel@lists.freedesktop.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi!

On Mon, 28 Apr 2014 10:09:17 +0200, I wrote:
> On Sun, 27 Apr 2014 15:55:29 -0400, Jerome Glisse <j.glisse@gmail.com> wr=
ote:
> > If my ugly patch works does this quirk also work ?
>=20
> Unfortunately they both don't; see my other email,
> <http://news.gmane.org/find-root.php?message_id=3D%3C87sioxq3rx.fsf%40sch=
winge.name%3E>.

> [...] hacked around as follows: [...]

> If needed, I can try to capture more data, but someone who has knowledge
> of PCI bus architecture and Linux kernel code (so, not me), might
> probably already see what's wrong.

The problem "solved itself": the machine recently died of hardware
failure.  ;-|


Gr=C3=BC=C3=9Fe,
 Thomas

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJTnpi4AAoJENuKOtuXzphJSy4H/iVeV8s9nQDKTRe0H+6VuyOa
joqGgQkfanZ35xocDxEStKDD/HP5szeCE87m0dseuHqZusIH5Npeb5dNH8Ss5cZA
4htw5IFTqDSOw5Dv2zfuAagPf0uCLAtqJv55FHlpI4kwWmeKISAkb9OAyUK/f1oA
Wu1KbriIm9D2nFL1R1yTfvC9NYLuGDOvL4sis+4IqTRRIpeTZMAMDwwE/cBygPDE
4+No5wYStNsqgu8uxQTU5arNtPFK8uDK/9+lKYkXU4TyFhpOEJEKQNStLRSNtq6s
//0748KW1HdE2/9yfXbfDfrGtXNpWMFarvOXkOT4/iCvzfQ2nf1+9N1pF0VxnQg=
=wH4w
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
