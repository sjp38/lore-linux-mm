Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 357006B007E
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 15:22:26 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id t184so36270064qkh.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 12:22:26 -0700 (PDT)
Received: from omr1.cc.vt.edu (omr1.cc.ipv6.vt.edu. [2607:b400:92:8300:0:c6:2117:b0e])
        by mx.google.com with ESMTPS id w206si13754396qhc.124.2016.04.14.12.22.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 12:22:25 -0700 (PDT)
Subject: Re: linux-next crash during very early boot
From: Valdis.Kletnieks@vt.edu
In-Reply-To: <20160414013546.GA9198@js1304-P5Q-DELUXE>
References: <3689.1460593786@turing-police.cc.vt.edu>
 <20160414013546.GA9198@js1304-P5Q-DELUXE>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1460661743_2431P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 Apr 2016 15:22:23 -0400
Message-ID: <39499.1460661743@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--==_Exmh_1460661743_2431P
Content-Type: text/plain; charset=us-ascii

On Thu, 14 Apr 2016 10:35:47 +0900, Joonsoo Kim said:

> My fault. It should be assgined every time. Please test below patch.
> I will send it with proper SOB after you confirm the problem disappear.
> Thanks for report and analysis!

Still bombs out, sorry.  Will do more debugging this evening if I have
a chance - will follow up tomorrow morning US time....

--==_Exmh_1460661743_2431P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVw/t7wdmEQWDXROgAQLczxAAqjkYzz4s7U9mkzMW2nqO42cdfA7sW1K4
Z4fBISAnEtcn6PwjE7UJeMZOtHqMRNd057o1YbO+YIRdm7XLXgMNBmvv6+80W/RR
gri+sJSXHCl02LHB5FYOu8+/fwVYp9DMaJyrZ+a+G8h7HQV+2xoiW0g+/izEtZTK
bCcdBND2rn8WSQ0PPmV1EyUpEidJcj6Foi+teWhp+Syl/1wxi/s7Pruj+uH3Q+FA
9aXBdXIjSHMgxiPYeXeHadJu2MKqohjjJ5XUQ2xdLeygneuAj1wbMXtFbGOBItGF
bF3Xp+XN/HDYbj3PRlvlCxBrFH1RoNXSZ2v/DrVTRLJ7ohlkLTH5Y92sXKtBdZOj
nVQeJPL6EQQ3KYM3+5XDjCPZJCAZCIanptgJCCNlncyHlIeVeGVlJshWAo/7PKJz
QA8VmbgdNtG8RRnaaxJSzkK1LVNiR0afV230aQ/XFi3G1gmiUsRDVQ/UpUT90CAL
fwVVX4TfZkCiFeDm5ah3GmYbU+KIOvQoM2lwJSDIRaFEpsb6JmlmXcG6sgQk8uTx
Q9V/8WoVnhlls2zIo4kQJLfqEwpTzBvo07TcRfsnjempuyqN8K4AdxqF1DlqU6MS
dp65xtPeIQQwdlFYT1x+j03cSNQYVjSC5mJhZQs3k3izQXgU0YzXEA/Itvb+VUww
GMJ2cBtM/Ao=
=JSuh
-----END PGP SIGNATURE-----

--==_Exmh_1460661743_2431P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
