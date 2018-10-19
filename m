Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 23B496B0266
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 14:49:22 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id r77-v6so36899374qke.3
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 11:49:22 -0700 (PDT)
Received: from omr2.cc.vt.edu (omr2.cc.ipv6.vt.edu. [2607:b400:92:8400:0:33:fb76:806e])
        by mx.google.com with ESMTPS id x4-v6si1239058qkh.210.2018.10.19.11.49.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Oct 2018 11:49:21 -0700 (PDT)
Received: from mr1.cc.vt.edu (mr1.cc.ipv6.vt.edu [IPv6:2607:b400:92:8300:0:31:1732:8aa4])
	by omr2.cc.vt.edu (8.14.4/8.14.4) with ESMTP id w9JInKVk018939
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 14:49:20 -0400
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by mr1.cc.vt.edu (8.14.7/8.14.7) with ESMTP id w9JInFR0023314
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 14:49:20 -0400
Received: by mail-qk1-f199.google.com with SMTP id m63-v6so36814055qkb.9
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 11:49:20 -0700 (PDT)
From: valdis.kletnieks@vt.edu
Subject: Re: [PATCH v3 1/2] mm: Add an F_SEAL_FUTURE_WRITE seal to memfd
In-Reply-To: <CAEXW_YTS2n2tOpXs3eVQZhYu7tmM_at0ZBA-04qYkHw4UE80nw@mail.gmail.com>
References: <20181018065908.254389-1-joel@joelfernandes.org> <42922.1539970322@turing-police.cc.vt.edu>
 <CAEXW_YTS2n2tOpXs3eVQZhYu7tmM_at0ZBA-04qYkHw4UE80nw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1539974951_3102P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Fri, 19 Oct 2018 14:49:11 -0400
Message-ID: <118792.1539974951@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@android.com>, John Reck <jreck@google.com>, John Stultz <john.stultz@linaro.org>, Todd Kjos <tkjos@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Christoph Hellwig <hch@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Daniel Colascione <dancol@google.com>, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, linux-fsdevel@vger.kernel.org, linux-kselftest <linux-kselftest@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, marcandre.lureau@redhat.com, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@kernel.org>, Shuah Khan <shuah@kernel.org>, Thomas Gleixner <tglx@linutronix.de>

--==_Exmh_1539974951_3102P
Content-Type: text/plain; charset=us-ascii

On Fri, 19 Oct 2018 10:57:31 -0700, Joel Fernandes said:
> On Fri, Oct 19, 2018 at 10:32 AM,  <valdis.kletnieks@vt.edu> wrote:
> > What is supposed to happen if some other process has an already existing R/W
> > mmap of the region?  (For that matter, the test program doesn't seem to
> > actually test that the existing mmap region remains writable?)

> Why would it not remain writable? We don't change anything in the
> mapping that prevents it from being writable, in the patch.

OK, if the meaning here is "if another process races and gets its own R/W mmap
before we seal our mmap, it's OK".  Seems like somewhat shaky security-wise - a
possibly malicious process can fail to get a R/W map because we just sealed it,
but if it had done the attempt a few milliseconds earlier it would have its own
R/W mmap to do as it pleases...

On the other hand, decades of trying have proven that trying to do any sort
of revoke() is a lot harder to do than it looks...

> We do test that existing writable mmaps can continue to exist after
> the seal is set, in a way, because we test that setting of the seal
> succeeds.

Well, if the semantics are "We don't bother trying to deal with existing R/W
maps", then it doesn't really matter - I was thinking along the lines of "If we're
revoking other R/W accesses, we should test that we didn't nuke *this* one in
the bargain"....

--==_Exmh_1539974951_3102P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Comment: Exmh version 2.8.0 04/21/2017

iQEVAwUBW8onJ40DS38y7CIcAQK8gAgAn0hFoG/7NzVOy5Rst3e/VtBaNha/e3V0
N+mOczsxE3dMEijB1Uyu9c9Lzla9XW612XLu/DIgfET40+gYywBE39PQQovZomc3
QEc1GfcRkVUQqncDVvKSAN9JQ7QdWLTvqAva+ChFl8+yAn2Y7hCqg+WHKT7XMqVZ
IQl7IZxHgfik1Id2h5IizZgSeBS91WoYehfIrgH59TcFA+Fjek8beOJpBvC4es3m
jDyp2LTlACh55TkUM3N7pQtKsNGSMUSekMG+ylFykgY76LS+K1rS9KBpABMFZL0Y
+McJX3of+FHEVoJy2W42G6+SRr82+4pVysAeVa8XxGRvS/wvMgTySQ==
=GvDD
-----END PGP SIGNATURE-----

--==_Exmh_1539974951_3102P--
