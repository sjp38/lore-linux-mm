Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0AFAD6B0253
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 20:40:53 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e190so2688614pfe.3
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 17:40:53 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id e127si422089pfa.13.2016.04.25.17.40.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 17:40:52 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id y69so53469703pfb.1
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 17:40:52 -0700 (PDT)
Received: from htb-2n-eng-dhcp436.eng.vmware.com ([208.91.1.34])
        by smtp.gmail.com with ESMTPSA id h88sm9627813pfd.10.2016.04.25.17.40.51
        for <linux-mm@kvack.org>
        (version=TLSv1/SSLv3 cipher=OTHER);
        Mon, 25 Apr 2016 17:40:51 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: x86: possible store-tearing in native_set_pte?
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <BB81219D-9DAC-4A88-8029-C40E8D69D708@gmail.com>
Date: Mon, 25 Apr 2016 17:40:51 -0700
Content-Transfer-Encoding: 7bit
Message-Id: <C38292D5-A96B-41CA-B037-60D28326668A@gmail.com>
References: <BB81219D-9DAC-4A88-8029-C40E8D69D708@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Resending with fixed formatting (sorry for that):

Can someone please explain why it is ok for native_set_pte to assign
the PTE without WRITE_ONCE() ?

Isn't it possible for a PTE write to be torn, and the PTE to be
prefetched in between (or even used for translation by another core)?

I did not encounter this case, but it seems to me possible according
to the documentation:

Intel SDM 4.10.2.3 "Detail of TLB Use": "The processor may cache
translations required for prefetches and for accesses ... that would
never actually occur in the executed code path."

Documentation/memory-barriers.txt: "The compiler is within its rights
to invent stores to a variable".

Thanks,
Nadav

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
