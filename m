Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 58C1B6B0035
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 11:30:25 -0400 (EDT)
Received: by mail-qa0-f41.google.com with SMTP id dc16so1630055qab.0
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 08:30:25 -0700 (PDT)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.232])
        by mx.google.com with ESMTP id y10si8785657qaj.18.2014.06.05.08.30.24
        for <linux-mm@kvack.org>;
        Thu, 05 Jun 2014 08:30:24 -0700 (PDT)
Message-ID: <53908D10.7080809@ubuntu.com>
Date: Thu, 05 Jun 2014 11:30:24 -0400
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: Dump struct page array?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Is there a way to dump the struct page array or perhaps even a tool to analyze it?  I would like to get a map of what pages are in use, or in particular, where all of the unmovable pages are.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (MingW32)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJTkI0QAAoJEI5FoCIzSKrwcrcH/AiOUvh5osAFezgR2pGlp3Iy
G+rvqzHdgFFef2RX057ehK+lj2nW8fNFyCy/zKR0aaueyH88yj4nFgoZw060cklo
0P5Fcvim1BKhPMUpD+0J8XaFEP9WD95/Q5XPqmfSUf64VrwPQSLcppwUJPO+ec7D
PBEctU9EvnXKPtrQRui44t6U0VRRvsN2OaRI8tZR7ou7V0FrOe86GdyXFRu8dsTN
22hy9A0JqTldjM9ebbr8xCu5cRRQFkUZSFqBv2lnnox+V8/1M8N8ZwCbkayQiyMQ
pW7DMTottjGsXrq/+l96UF2aWQv5PIof9NR4FJ3YSFdo1YvTfUozSLbX24KCQFI=
=t4Q0
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
