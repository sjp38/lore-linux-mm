Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 336556B0035
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 05:45:13 -0400 (EDT)
Received: by mail-qa0-f54.google.com with SMTP id n8so9849072qaq.27
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 02:45:12 -0700 (PDT)
Received: from omr1.cc.vt.edu (omr1.cc.ipv6.vt.edu. [2001:468:c80:2105:0:2fc:76e3:30de])
        by mx.google.com with ESMTPS id b9si17052695qar.75.2014.09.30.02.45.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Sep 2014 02:45:11 -0700 (PDT)
Subject: Re: [PATCH v11 00/21] Add support for NV-DIMMs to ext4
In-Reply-To: Your message of "Thu, 25 Sep 2014 16:33:17 -0400."
             <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
From: Valdis.Kletnieks@vt.edu
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1412070301_2231P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Tue, 30 Sep 2014 05:45:01 -0400
Message-ID: <15705.1412070301@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>

--==_Exmh_1412070301_2231P
Content-Type: text/plain; charset=us-ascii

On Thu, 25 Sep 2014 16:33:17 -0400, Matthew Wilcox said:

> Patch 19 adds some DAX infrastructure to support ext4.
>
> Patch 20 adds DAX support to ext4.  It is broadly similar to ext2's DAX
> support, but it is more efficient than ext4's due to its support for
> unwritten extents.

I don't currently have a use case for NV-DIMM support.

However, it would be nice if this code could be leveraged to support
'force O_DIRECT on all I/O to this file' - that I *do* have a use
case for.  Patch 20 looks to my untrained eye like it *almost* gets
there.

(And if in fact it *does* do the whole enchilada, the Changelog etc should
mention it :)


--==_Exmh_1412070301_2231P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVCp7nQdmEQWDXROgAQLv+Q/+MJrrdItGQo9RwAqKyVmn7uJA2UWWmBJ2
8otETBMl0IQHv+JHbQTUynXMD6AgKpBrAjkW56dTVc5XhnHIwR7ZzYfriYmp6jpe
TdNb3iYP1zpKbixfHSCIhmacmJEk9tNYJdSTH1RKagFGM7DRA3LaG5A3PvEr/RGZ
NpMgADZDUA3AbDT0CQkBVGJ5Y6osPAVq/fD6S0vyvUsmLAVsrtpYMPsJXXh6NaNw
5qoFjnBNkopPVIDY0vqcqJgNUC0bVRtgkrxhiwDnhzxVdz+qOAri8GbiHkKzAhB+
iXIbxUl+IH+BVAgmrMZPJA3MDr4U1bCj+dfNlfYI+Mgubm1hzSQEf4re9wcVjWiG
lyV2NpxhQHkV1P+nw0gVvGd8e5qOWd2WLMdqo4UOGeUSYukhlR4BrkUs8FVt/4Jh
a/nWascldQ4Lap270vrHRN8oKp9VRz8WoIqzugOg3Nuhtplg6bol5p6y3HnaCUFI
dclwFW3OT0dDWODZFzXdOZQfCDoEbDwP0Zbk6C42XriNgm7cHEv4Mr06aahC81zo
/oCZAosXBy61k13hKxRbDR4AHen1oEW/rKNlzhviOCbiIfk2eIrpwgSWtaKRyU5b
nAvNr0JrjjmNG+K3AftGxa5wPl+cU1lSYM2gKYiawTH5210CbwfCSQ6j+1q4l2ch
EMrC7MqtG0o=
=q9v8
-----END PGP SIGNATURE-----

--==_Exmh_1412070301_2231P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
