Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9B9B2900138
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 19:23:18 -0400 (EDT)
Subject: Re: [PATCH] mmap: add sysctl for controlling ~VM_MAYEXEC taint
In-Reply-To: Your message of "Tue, 16 Aug 2011 10:07:46 PDT."
             <CAB=4xhqu1FsJnNbHNeokyROvEFpRJYKhcHRLLw5QTVKOkbkWfQ@mail.gmail.com>
From: Valdis.Kletnieks@vt.edu
References: <1313441856-1419-1-git-send-email-wad@chromium.org> <20110816093303.GA4484@csn.ul.ie>
            <CAB=4xhqu1FsJnNbHNeokyROvEFpRJYKhcHRLLw5QTVKOkbkWfQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1313623354_2796P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Wed, 17 Aug 2011 19:22:35 -0400
Message-ID: <26032.1313623355@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roland McGrath <mcgrathr@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Al Viro <viro@zeniv.linux.org.uk>, Eric Paris <eparis@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Nitin Gupta <ngupta@vflare.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org

--==_Exmh_1313623354_2796P
Content-Type: text/plain; charset=us-ascii

On Tue, 16 Aug 2011 10:07:46 PDT, Roland McGrath said:

> I think the expectation is that the administrator or system builder
> who decides to set the (non-default) noexec mount option will also
> set the sysctl at the same time.

On the other hand, a design that requires 2 separate actions to be taken in
order to make it work, and which fails unsafe if the second step isn't taken,
is a bad design. If we're talking "expectations", let's not forget that the
mount option is called "noexec", not "only-really-noexec-if-you-set-a-magic-sysctl". 

I'll also point out that we didn't add a sysctl in 2.6.0 to say whether or not
to still allow the old "/lib/ld-linux.so your-binary-here" hack to execute binaries
off a partition mounted noexec - we simply said "this will no longer be permitted".

--==_Exmh_1313623354_2796P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFOTE06cC3lWbTT17ARArvUAKDn6sm9pSqqg7YUK9N/vKxyJ5+bZgCg4o87
t2rPh/FpyLsAJFxJFeBX0/0=
=PKOP
-----END PGP SIGNATURE-----

--==_Exmh_1313623354_2796P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
