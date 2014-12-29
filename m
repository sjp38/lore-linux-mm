Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1551F6B0038
	for <linux-mm@kvack.org>; Sun, 28 Dec 2014 19:43:43 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so16356913pab.18
        for <linux-mm@kvack.org>; Sun, 28 Dec 2014 16:43:42 -0800 (PST)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.227])
        by mx.google.com with ESMTP id d2si30592840pat.238.2014.12.28.16.43.40
        for <linux-mm@kvack.org>;
        Sun, 28 Dec 2014 16:43:41 -0800 (PST)
Message-ID: <54A0A3BB.1070908@ubuntu.com>
Date: Sun, 28 Dec 2014 19:43:39 -0500
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: Memory / swap leak?
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Something seems to be eating up all of my swap, but it defies explanation:

root@faldara:~# free -m
             total       used       free     shared    buffers     cached
Mem:          3929       2881       1048        146        192       1314
- -/+ buffers/cache:       1374       2555
Swap:         2047       2047          0

root@faldara:~# (for file in /proc/*/status ; do cat $file ; done) |
awk '/VmSwap/{sum += $2}END{ print sum}'
151804

So according to free, my entire 2 gb of swap is used, yet according to
proc, the total swap used by all processes in the system is only 151
mb.  How can this be?

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBCgAGBQJUoKO7AAoJENRVrw2cjl5ReXwH/3bS3ZUSU3ej0xiW+LwVMULg
MBJN43Jy4VCmaRbfs6HuDBmNINffGoPg2sV4Uq/fOyzhWdgL7FduT9eSkHtueO/M
yvVCN+gawtD1izdPL35XnWXyxaz8RWLA5kkUw8ze2HUEkFd1q6GRCLalweUdruxN
HVBE3EGSYWLkDD++2b4EVpjYeg7I/Zf85gLYMRGUQki4630VHfWgf9l+SlGWgVRC
u8EToFeORLglrq7t1tf5Y+p/3h/l0iyqGwrzUb8qnloTfsWQadUmoffmW8LMrp+7
THdW77JwPp/R+KAFd7tvDD0AcGOZ4+fHa+pXDpGF+3pH6/w12JlOp+gbJoHRu5w=
=m+bq
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
