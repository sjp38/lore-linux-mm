Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 891C16B0035
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 10:53:58 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id x13so1574318qcv.14
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 07:53:58 -0700 (PDT)
Received: from omr2.cc.vt.edu (omr2.cc.ipv6.vt.edu. [2001:468:c80:2105:0:24d:7091:8b9c])
        by mx.google.com with ESMTPS id q79si5779323qgq.91.2014.09.30.07.53.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Sep 2014 07:53:57 -0700 (PDT)
Subject: Re: [PATCH v11 00/21] Add support for NV-DIMMs to ext4
In-Reply-To: Your message of "Tue, 30 Sep 2014 10:48:54 -0400."
             <20140930144854.GA5098@wil.cx>
From: Valdis.Kletnieks@vt.edu
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com> <15705.1412070301@turing-police.cc.vt.edu>
            <20140930144854.GA5098@wil.cx>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1412088827_2231P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Tue, 30 Sep 2014 10:53:47 -0400
Message-ID: <123795.1412088827@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--==_Exmh_1412088827_2231P
Content-Type: text/plain; charset=us-ascii

On Tue, 30 Sep 2014 10:48:54 -0400, Matthew Wilcox said:

> No, it doesn't try to do that.  Wouldn't you be better served with an
> LD_PRELOAD that forces O_DIRECT on?

Not when you don't want it on every file, and users are creating and
deleting files once in a while.  A chattr-like command is easier and
more scalable than rebuilding the LD_PRELOAD every time the list of
files gets changed....

--==_Exmh_1412088827_2231P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVCrD+wdmEQWDXROgAQLYxw/+KGYWwJ0+oHZ6w4rAsmBsZGNLmCjxPEQc
W4JimJCgapPxYR62Tk4njVsMAQtktGGxrnpg2uw3glO5093FJkc3DblQTT31ram4
B/Vx17WwkB2X+j2E4zng0tuERF0QPuGgTGp/zfEVcDcR1oUftI8VFUoejdllGPyi
wyboTr47oVpethWRPhc/25/y5J0f6aZUSxybMYo9qGygaMxGbjmDPt6l0QSyxSty
hcEsAYSsjOpiA6yDe/8frog93FrsTuJQtFq5tHk/PC39bRp7zFWQZIUQhH74kPUU
oT3MCN0qtKNA9ed36pRmNTVeInrRoGXrkANEFQYHdLL9v/ranNj1pb06TzBTQdvH
tXmEVfiTZH+ZG2RWDPmBbs1Zjt3ASuhSCeymxHNscgOuaDH3+jigUpj1cOYmmWgT
9IeR+2TlJVpA5jkT1akm5Y+gqIMK7WlnmanksnAoRUz/7rmJvFwYtfzpak5XX1Nb
YmbZvwfiZDWMGvpUl9YdH53sB+KG2TVDkKy6UP+pZtWCUyfhCpALMldAlXm1spTh
kfehsJZNO0BzYQGNJ9HBw75toK1zoBdPiULuzdq3AH50rVAY6Z8SxApwwemx5zld
P6T6ZUgZDqTNhedhuBZ1/1NxIBSx7JiJcu/rBA8y44TJBBfQRpevLHVgjUkNmSSH
5yU6Hwlbig0=
=oz0U
-----END PGP SIGNATURE-----

--==_Exmh_1412088827_2231P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
