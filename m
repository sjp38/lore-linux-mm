Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 67FE66B0036
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 13:15:39 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so1304188pab.32
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 10:15:39 -0700 (PDT)
Message-ID: <524C54B8.2060107@ubuntu.com>
Date: Wed, 02 Oct 2013 13:15:36 -0400
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: readahead man page incorrectly says it blocks
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

The man page for readahead(2) incorrectly claims that it blocks until
all of the requested data has been read.  I filed a bug a few months
ago to have this corrected, but I think it is being ignored now
because they don't believe me that it isn't supposed to block.  Could
someone help back me up and get this fixed?

https://bugzilla.kernel.org/show_bug.cgi?id=54271

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (MingW32)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJSTFS4AAoJEJrBOlT6nu756hwIAJKQZnvazqLi8excUCrqc+HQ
TSokhlBLBqRtk5nGN6X0UpDZ6KPFn0qsRpnhQApyk46nU/ru1YbbZLEtHgrWwaFW
g2V+L248hIyYOYSAr/RCj9g4Zx5yMit6BOM1virD0VJ0cRDSA6mbNI0bVmTxEf+f
9UF2rwnXW63u3NwGjEMboVWCCOrfV3AGCTC31KTY/e2e1SUIlD8IIaRxW0RkVmVj
PCmSVPvpaZoLaDgQ0F+sBBzLrCp9r72UT7j58Zzurj1GaIG2VEVAXKKij0b2Xtxg
vjzflgrMd72pLhb+ppk/RP20FWmp6PJ3wKbK7zVrvILVHzSaoncDApURG/nBpHE=
=zmD3
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
