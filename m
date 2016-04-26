Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 47BEE6B0005
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 20:24:17 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id vv3so296095680pab.2
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 17:24:17 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id j9si888903paf.186.2016.04.25.17.24.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 17:24:16 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id c189so28301364pfb.3
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 17:24:16 -0700 (PDT)
Received: from htb-2n-eng-dhcp436.eng.vmware.com ([208.91.1.34])
        by smtp.gmail.com with ESMTPSA id a5sm32903627pat.19.2016.04.25.17.24.15
        for <linux-mm@kvack.org>
        (version=TLSv1/SSLv3 cipher=OTHER);
        Mon, 25 Apr 2016 17:24:15 -0700 (PDT)
From: Nadav Amit <nadav.amit@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: x86: possible store-tearing in native_set_pte?
Message-Id: <BB81219D-9DAC-4A88-8029-C40E8D69D708@gmail.com>
Date: Mon, 25 Apr 2016 17:24:14 -0700
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Can someone please explain why it is ok for native_set_pte to assign the =
PTE
without WRITE_ONCE() ?

Couldn=E2=80=99t a PTE write be torn, and the PTE be prefetched in =
between (or even
used for translation by another core)?

I did not encounter this case, but it seems to me possible according to =
the
documentation:

Intel SDM 4.10.2.3 =E2=80=9CDetail of TLB Use": "The processor may cache
translations required for prefetches and for accesses ... that would =
never
actually occur in the executed code path.=E2=80=9D

Documentation/memory-barriers.txt: "The compiler is within its rights to
invent stores to a variable=E2=80=9D.

Thanks,
Nadav=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
