Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7076B0035
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 15:33:50 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id s7so2045419qap.6
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 12:33:50 -0700 (PDT)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.231])
        by mx.google.com with ESMTP id l65si9458016qge.91.2014.06.05.12.33.49
        for <linux-mm@kvack.org>;
        Thu, 05 Jun 2014 12:33:49 -0700 (PDT)
Message-ID: <5390C61C.1020500@ubuntu.com>
Date: Thu, 05 Jun 2014 15:33:48 -0400
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: Re: Dump struct page array?
References: <53908D10.7080809@ubuntu.com> <CALYGNiNupJLmMV4ehMb9r9hxefBmbLoW2aZ2E0eZ=C=Y1rDXZQ@mail.gmail.com>
In-Reply-To: <CALYGNiNupJLmMV4ehMb9r9hxefBmbLoW2aZ2E0eZ=C=Y1rDXZQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 6/5/2014 11:56 AM, Konstantin Khlebnikov wrote:
| On Thu, Jun 5, 2014 at 7:30 PM, Phillip Susi <psusi@ubuntu.com> wrote:
| Is there a way to dump the struct page array or perhaps even a tool to
| analyze it?  I would like to get a map of what pages are in use, or in
| particular, where all of the unmovable pages are.
|
|> Have you seen "page-types"? tools/vm/page-types.c in the kernel source tree.

Thanks, that is very interesting... I noticed that there are no reserved pages.  There *must* be some pages marked as reserved for the bios somewhere right?  Also how do you tell what pages are free or allocated to the kernel?  It seems that free pages sometimes have the buddy bit set and sometimes not, and pages used by the slab cache sometimes have the slab bit set, and sometimes not.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (MingW32)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJTkMYcAAoJEI5FoCIzSKrwq28H/18Y/O+u/ZTT7ICVvUUjM5YP
LNb43Nf/7uvaE/ElMiemGdzqSzUcf4wb93HtVeV3OmuV/ALk1H/eaYFLpxxq1sGI
hXojGoqaHUwHTie//3Xq3C4Dfi0jDqC7tTX6uywSDRdCzbq2TOGuruc+0n0k3r7b
MCQC+Vqr+mzW0d8U8EVE6ux8noA9FlUMFdNDTJAMEbZiyfKdjFXCua4lnVPope/h
yB3M4Th+eYY6YGvPoEPfJeYSdeqNGwW2JH6zRGokVk7i21D1G8vudMmwMYziso5D
YmTeLvrLhQw3tnX1O0Y7MKepRabx9vqhbruK+5RzTQYl1UZYZEnZ3NO6ithC+UU=
=bkUL
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
