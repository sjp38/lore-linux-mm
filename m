Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id AB9F86B0033
	for <linux-mm@kvack.org>; Fri, 17 May 2013 10:54:24 -0400 (EDT)
Message-ID: <5196449F.9080108@ubuntu.com>
Date: Fri, 17 May 2013 10:54:23 -0400
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

iQEcBAEBAgAGBQJRlkSfAAoJEJrBOlT6nu75vcIH/0bVb3BGAr+obffnDgugX+EB
LAQaj/p83vNV9ND8alsSg0c+Q8iX8m4klSgsiYg78NdM8x0+V1je5n934/KqUTO1
eHWLf+7GcRJ7CuBctaY2U0uSWWrhMjhPqD1HBlTplqH3Wj3xxIf9T4Ym2K4+BW1Z
yx2XAPhmWy57EBE4MtxUSVd01jINZZpyuv2oOCqblLfmUKTWzJvm12eDjnrYQq1/
Ar7trfjFE4HXIyTHIEgQazoi9D4dF8yFHgndd89ZQ2yvSkwe59UXDyequm6IrOCz
mAqIwUS0N5xJ1AdJp6ruZd1VAzyFzZy2Il8XMLLhc9GSPDiXApWiM57oK7DDiFA=
=4Fmb
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
