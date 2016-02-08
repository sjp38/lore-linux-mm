Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f53.google.com (mail-lf0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1714F8309E
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:00:36 -0500 (EST)
Received: by mail-lf0-f53.google.com with SMTP id m1so92258247lfg.0
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:00:36 -0800 (PST)
Received: from mail-lb0-x230.google.com (mail-lb0-x230.google.com. [2a00:1450:4010:c04::230])
        by mx.google.com with ESMTPS id kj13si11063032lbb.114.2016.02.08.01.00.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Feb 2016 01:00:34 -0800 (PST)
Received: by mail-lb0-x230.google.com with SMTP id cw1so78930090lbb.1
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:00:34 -0800 (PST)
From: Dmitry Monakhov <dmonakhov@openvz.org>
Subject: [LSF/MM ATTEND] ext4, DAX pmem/fsync
Date: Mon, 08 Feb 2016 12:00:22 +0300
Message-ID: <87lh6vwp95.fsf@openvz.org>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>
Cc: ext4 development <linux-ext4@vger.kernel.org>, linux-fsdevel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-nvme@lists.infradead.org" <linux-nvme@lists.infradead.org>

--=-=-=
Content-Type: text/plain



I would like to attend LSF/MM 2016 to participate in discussions around
the optimization of the block and MM for low latency NVM technologies.
Primary target of interests is to improving DAX performance for general
purpose FS.
While working on LightVM project (approach lighter that traditional VM, but more
secure that containers) we found that existing DAX infrastructure is too
far from optimum:
0) DAX msync/fsync patch-set is has a lot in TODO list
1) DAX implementation has number of significant SMP scalability issues.

I would like to attend LSF/MM this year. I believe I could contribute to the
following discussions:

*  Block & Filesystem interface from Steven Whitehouse
http://www.spinics.net/lists/linux-fsdevel/msg93552.html

* Persistent memory: pmem as storage device vs pmem as memory from Dan Williams
https://lists.01.org/pipermail/linux-nvdimm/2016-February/004331.html

* Persistent Memory Error Handling from Jeff Moyer:
http://www.spinics.net/lists/linux-mm/msg100560.html

* FS block allocator modification for SMR Zoned Block Devices

* EXT4-mini sumit

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBCgAGBQJWuFkmAAoJELhyPTmIL6kBHs0IAKI3pxTEtxh+HP7/p35tyF7y
dzrKslTM8WQei81b7GvaYNGiZJNJDhJxnGLI5rwtdFtVeHXkAjmuaKCe5uBPg8LN
Ua97xhMNdXSypFZdR77ZTT/3YG+BV+33m275HjZZZxnQQkbKcwLK1+m3hyDN+esH
CiNzw2Fv06KQuUpi1oS8yZssXR0PaufyoEJMN+a1WMhRaULL4pYTpaOh0dmt0Usr
UdBT/2EO2GuOsQBS2gMbWbIS8nzYFKsL1Tnz9IusRSEUJdOxKLBZcrS9QRtOK8v7
x9CxGf1tjjhzT1KgSWg8CLvP2ZaW3otx2zIxMsROlGIrRFLIpqQwhSPiryvvj/s=
=Xj9q
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
