Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 3539B6B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 14:07:01 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so115323126pdb.2
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 11:07:00 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id ht3si10613261pdb.137.2015.03.20.11.05.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Mar 2015 11:06:22 -0700 (PDT)
Message-ID: <550C6151.8070803@oracle.com>
Date: Fri, 20 Mar 2015 12:05:05 -0600
From: David Ahern <david.ahern@oracle.com>
MIME-Version: 1.0
Subject: Re: 4.0.0-rc4: panic in free_block
References: <550C37C9.2060200@oracle.com>	<CA+55aFxhNphSMrNvwqj0AQRzuqRdPG11J6DaazKWMb2U+H7wKg@mail.gmail.com>	<550C5078.8040402@oracle.com> <CA+55aFyQWa0PjT-3y-HB9P-UAzThrZme5gj1P6P6hMTTF9cMtA@mail.gmail.com>
In-Reply-To: <CA+55aFyQWa0PjT-3y-HB9P-UAzThrZme5gj1P6P6hMTTF9cMtA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
Cc: "David S. Miller" <davem@davemloft.net>, LKML <linux-kernel@vger.kernel.org>, sparclinux@vger.kernel.org

On 3/20/15 10:58 AM, Linus Torvalds wrote:
> That said, SLAB is probably also almost unheard of in high-CPU
> configurations, since slub has all the magical unlocked lists etc for
> scalability. So maybe it's a generic SLAB bug, and nobody with lots of
> CPU's is testing SLAB.
>

Evidently, it is a well known problem internally that goes back to at 
least 2.6.39.

To this point I have not paid attention to the allocators. At what point 
is SLUB considered stable for large systems? Is 2.6.39 stable?

As for SLAB it is not clear if this is a sparc only problem. Perhaps the 
config should have a warning? It looks like SLAB is still the default 
for most arch.

DaveM: do you mind if I submit a patch to change the default for sparc 
to SLUB?

Now that the monster is unleashed, off to other problems...

Thanks,
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
