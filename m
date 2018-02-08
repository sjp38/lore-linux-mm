Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 40F406B0005
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 12:58:52 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id c195so4316432qkg.0
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 09:58:52 -0800 (PST)
Received: from omr1.cc.vt.edu (omr1.cc.ipv6.vt.edu. [2607:b400:92:8300:0:c6:2117:b0e])
        by mx.google.com with ESMTPS id o184si455994qkf.47.2018.02.08.09.58.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 09:58:51 -0800 (PST)
Received: from mr4.cc.vt.edu (junk.cc.ipv6.vt.edu [IPv6:2607:b400:92:9:0:9d:8fcb:4116])
	by omr1.cc.vt.edu (8.14.4/8.14.4) with ESMTP id w18HwooB016247
	for <linux-mm@kvack.org>; Thu, 8 Feb 2018 12:58:50 -0500
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by mr4.cc.vt.edu (8.14.7/8.14.7) with ESMTP id w18HwjAm026526
	for <linux-mm@kvack.org>; Thu, 8 Feb 2018 12:58:50 -0500
Received: by mail-qk0-f198.google.com with SMTP id t12so4269838qke.22
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 09:58:50 -0800 (PST)
From: valdis.kletnieks@vt.edu
Subject: Re: [RFC] Warn the user when they could overflow mapcount
In-Reply-To: <CAG48ez2-MTJ2YrS5fPZi19RY6P_6NWuK1U5CcQpJ25=xrGSy_A@mail.gmail.com>
References: <20180208021112.GB14918@bombadil.infradead.org>
 <CAG48ez2-MTJ2YrS5fPZi19RY6P_6NWuK1U5CcQpJ25=xrGSy_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1518112722_2958P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Thu, 08 Feb 2018 12:58:42 -0500
Message-ID: <24367.1518112722@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, Kernel Hardening <kernel-hardening@lists.openwall.com>, kernel list <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

--==_Exmh_1518112722_2958P
Content-Type: text/plain; charset=us-ascii

On Thu, 08 Feb 2018 03:56:26 +0100, Jann Horn said:

> I wouldn't be too surprised if there are more 32-bit overflows that
> start being realistic once you put something on the order of terabytes
> of memory into one machine, given that refcount_t is 32 bits wide -
> for example, the i_count. See
> https://bugs.chromium.org/p/project-zero/issues/detail?id=809 for an
> example where, given a sufficiently high RLIMIT_MEMLOCK, it was
> possible to overflow a 32-bit refcounter on a system with just ~32GiB
> of free memory (minimum required to store 2^32 64-bit pointers).
>
> On systems with RAM on the order of terabytes, it's probably a good
> idea to turn on refcount hardening to make issues like that
> non-exploitable for now.

I have at least 10 systems across the hall that have 3T of RAM on them
across our various HPC clusters.  So this is indeed no longer a hypothetical
issue.

--==_Exmh_1518112722_2958P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Comment: Exmh version 2.8.0 04/21/2017

iQEVAwUBWnyP0o0DS38y7CIcAQJvMwgAqINtG3XsiyureZeY7FTqdkwoqxA0BUmM
tUkyfbqu/6bfJmdPUOhV4a62wWIULi9xc/yTUcH3Ve/Y71KQVBWfz+QBeeMIihdr
Qh8b6SWWL5gViGCj0uw0d8pbwgzmX/PplJSgupP8j4tf3CyQ7FcrIBpB3p8PfocO
FINFQ/W8JiCVsTGlgmlcwAlTxTzmNP2EF7JoKp4Ugy/cBpxpN8B35/kawTBWirL4
f2OagdWoDdeyu+XyVEaBhybUuGhGVBnbYGELaaJ5A2uGfPhooVZEMzBDZbFgpesu
9jKlkll5COPF3fozpf6idD5uHYaWGUaYRw5rdH+7+eZ59JdRuYZoiw==
=eDZP
-----END PGP SIGNATURE-----

--==_Exmh_1518112722_2958P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
