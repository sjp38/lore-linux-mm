Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8E7F66B0003
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 13:32:11 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id r77-v6so36628474qke.3
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 10:32:11 -0700 (PDT)
Received: from omr2.cc.vt.edu (omr2.cc.ipv6.vt.edu. [2607:b400:92:8400:0:33:fb76:806e])
        by mx.google.com with ESMTPS id m185-v6si50065qkb.188.2018.10.19.10.32.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Oct 2018 10:32:10 -0700 (PDT)
Received: from mr1.cc.vt.edu (mr1.cc.ipv6.vt.edu [IPv6:2607:b400:92:8300:0:31:1732:8aa4])
	by omr2.cc.vt.edu (8.14.4/8.14.4) with ESMTP id w9JHWAEd019508
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 13:32:10 -0400
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by mr1.cc.vt.edu (8.14.7/8.14.7) with ESMTP id w9JHW5e0008437
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 13:32:10 -0400
Received: by mail-qk1-f199.google.com with SMTP id y201-v6so36546447qka.1
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 10:32:10 -0700 (PDT)
From: valdis.kletnieks@vt.edu
Subject: Re: [PATCH v3 1/2] mm: Add an F_SEAL_FUTURE_WRITE seal to memfd
In-Reply-To: <20181018065908.254389-1-joel@joelfernandes.org>
References: <20181018065908.254389-1-joel@joelfernandes.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1539970322_3102P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Fri, 19 Oct 2018 13:32:02 -0400
Message-ID: <42922.1539970322@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Cc: linux-kernel@vger.kernel.org, kernel-team@android.com, jreck@google.com, john.stultz@linaro.org, tkjos@google.com, gregkh@linuxfoundation.org, hch@infradead.org, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, dancol@google.com, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-mm@kvack.org, marcandre.lureau@redhat.com, Mike Kravetz <mike.kravetz@oracle.com>, minchan@kernel.org, Shuah Khan <shuah@kernel.org>, Thomas Gleixner <tglx@linutronix.de>

--==_Exmh_1539970322_3102P
Content-Type: text/plain; charset=us-ascii

On Wed, 17 Oct 2018 23:59:07 -0700, "Joel Fernandes (Google)" said:
> This usecase cannot be implemented with the existing F_SEAL_WRITE seal.
> To support the usecase, this patch adds a new F_SEAL_FUTURE_WRITE seal
> which prevents any future mmap and write syscalls from succeeding while
> keeping the existing mmap active. The following program shows the seal
> working in action:

What is supposed to happen if some other process has an already existing R/W
mmap of the region?  (For that matter, the test program doesn't seem to
actually test that the existing mmap region remains writable?)


--==_Exmh_1539970322_3102P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Comment: Exmh version 2.8.0 04/21/2017

iQEVAwUBW8oVEo0DS38y7CIcAQLWJQf8DQ1cQowO3bfaWQWZBNXxbcCeCMPYgp1w
3XFonoT+hSpd45gHazrRRXmfR3BJ0wb9wZHsE0CCCpmuXlNnH2WOmKB7/ly/5lb8
RQhT8ahp8/OzRpRnfDlLQEIbAY/5kT4XGRf1wjVBnonPYY8aXjSj44dyBIaPh8XZ
GJLYEL6++rWifApraHDHgBbMQCEn7HMXnvoHtIcV3/ihRj+bo7H74Cr8S7e6dPCP
sLtruVLu00SYYHkTI6l0rSAZiMiYJnVyuk3bju4jTMqX7KayRCmzS9X+65F5jb/M
qJhZ/DLjV/n3/DqK9u2z5tOsiN4scyW1ThQpK+tjXj0SC+9a0VoAoQ==
=fFpS
-----END PGP SIGNATURE-----

--==_Exmh_1539970322_3102P--
