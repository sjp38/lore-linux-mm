Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8B33E6B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 15:04:57 -0400 (EDT)
Received: by qcay5 with SMTP id y5so11094708qca.1
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 12:04:57 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id d109si5103058qge.52.2015.03.20.12.04.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Mar 2015 12:04:57 -0700 (PDT)
Message-ID: <550C6F53.5090707@oracle.com>
Date: Fri, 20 Mar 2015 13:04:51 -0600
From: David Ahern <david.ahern@oracle.com>
MIME-Version: 1.0
Subject: Re: 4.0.0-rc4: panic in free_block
References: <550C37C9.2060200@oracle.com>	<CA+55aFxhNphSMrNvwqj0AQRzuqRdPG11J6DaazKWMb2U+H7wKg@mail.gmail.com>	<550C5078.8040402@oracle.com>	<CA+55aFyQWa0PjT-3y-HB9P-UAzThrZme5gj1P6P6hMTTF9cMtA@mail.gmail.com>	<550C6151.8070803@oracle.com> <CA+55aFyE-zA3be7=FWZE_m2hVHwZueGvciSrghhQB3gT-UHrPA@mail.gmail.com>
In-Reply-To: <CA+55aFyE-zA3be7=FWZE_m2hVHwZueGvciSrghhQB3gT-UHrPA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, "David S. Miller" <davem@davemloft.net>, LKML <linux-kernel@vger.kernel.org>, sparclinux@vger.kernel.org

On 3/20/15 12:53 PM, Linus Torvalds wrote:
> SLUB should definitely be considered a stable allocator.  It's the
> default allocator for at least Fedora, and that presumably means all
> of Redhat.
>
> SuSE seems to use SLAB still, though, so it must be getting lots of
> testing on x86 too.
>
> Did you test with SLUB? Does it work there?

sorry, forgot to add that detail in the last response: it works fine. No 
panics at all with SLUB.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
