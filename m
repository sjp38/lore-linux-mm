Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id F243B6B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 05:13:04 -0400 (EDT)
Received: by mail-qg0-f50.google.com with SMTP id z60so712179qgd.37
        for <linux-mm@kvack.org>; Wed, 07 May 2014 02:13:04 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id 100si6457037qgf.137.2014.05.07.02.13.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 May 2014 02:13:04 -0700 (PDT)
Date: Wed, 7 May 2014 11:12:58 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC, PATCH 0/8] remap_file_pages() decommission
Message-ID: <20140507091258.GP11096@twins.programming.kicks-ass.net>
References: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20140506143542.1d4e5f41be58b3ad3543ffe3@linux-foundation.org>
 <CA+55aFwUO5ubckFFEF+R=yos-Qd3Br4Fy3-LpXL0bDWCmMhb6g@mail.gmail.com>
 <20140506230323.GA14821@node.dhcp.inet.fi>
 <20140506162856.2a94db336b91db5525ed0457@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tgO4DUqb0GCKXXLG"
Content-Disposition: inline
In-Reply-To: <20140506162856.2a94db336b91db5525ed0457@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>


--tgO4DUqb0GCKXXLG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, May 06, 2014 at 04:28:56PM -0700, Andrew Morton wrote:
> On Wed, 7 May 2014 02:03:23 +0300 "Kirill A. Shutemov" <kirill@shutemov.n=
ame> wrote:
>=20
> > remap_file_pages(2) was invented to be able efficiently map parts of
> > huge file into limited 32-bit virtual address space such as in database
> > workloads.
> >=20
> > Nonlinear mappings are pain to support and it seems there's no
> > legitimate use-cases nowadays since 64-bit systems are widely available.
> >=20
> > Let's deprecate remap_file_pages() syscall in hope to get rid of code
> > one day.
>=20
> Before we do this we should ensure that your proposed replacement is viab=
le
> and desirable.  If we later decide not to proceed with it, this patch will
> sow confusion.

Chicken meet Egg ?

How are we supposed to test if its viable if we have no known users? The
printk() might maybe (hopefully) get us some reaction in say a years
time, much longer if we're really unlucky.

That said, we could make the syscall return -ENOSYS unless a sysctl was
touched. The printk() would indeed have to mention said sysctl and a
place to find information about why we're doing this..

But by creating more pain (people have to actually set the sysctl, and
we'll have to universally agree to inflict pain on distro people that
set it by default -- say, starve them from beer at the next conf.) we're
more likely to get an answer sooner.



--tgO4DUqb0GCKXXLG
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTafkaAAoJEHZH4aRLwOS6dh0P/R4aD4PcQTnFviFy5YYyWiP9
TUUY53h/0MThhd61zYM1adtwE7hGrsD/SGZ+9k7vaqjUSqI6dcVBm9d6QiFei9jR
/FnWBnOHCEa2QvEa1IGDtunHlU1Ab04ML7f6xxmpjCsnPw0UtM/6+pRFkyb0z+mq
eVLc/f+CyLsUmqlZvgFlMTu8cYBIYf0jX22lDXhVBAcX7ll9exw7lJRc3ZGAdqgP
Vvz9nzzPsNwNkvPld/xHi1A0u9Wp2r/9SUyh850PO2jx8uWFBlMAAPkjr7vCaji6
e+SvL5aj2lKHsHBmdXYTdhbTl2n6egq55cpzNFmi2y+SSlYrIHOZaEYNfWy+xjdm
C93XH4nw0N8GfUW1gDCwtEEFbhpcSmgaPnw91bnwAUuhvxOdB7JrmhRVg+IvRFgm
xVWOGBwDi20U5bL153Mc++jMBrvy0/Mgp83unzeI2Ftl5X25AzZJeKjRGCFNXgmD
hf3l1jJiEuoLjQWDsdqGZa1va6mm3j+2ZqfpKNsDSrKbNu+A2AQ9iVwPwRL8Whve
1yBjNEYtknDuWjoKNkLa+H/C+Q7kwtz1iakCxwlPgtE0iHYv7PbJ1DBj7gCWjhqk
0OfJJ/yoDKD2bD9i0+qISFV4xM0gB2rlqKHw4BVAoJH3t189LsN97YosSvQEN0G8
xs0V8Qf+HpAcCju3oli2
=tzLB
-----END PGP SIGNATURE-----

--tgO4DUqb0GCKXXLG--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
