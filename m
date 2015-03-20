Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id D5B216B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 12:58:25 -0400 (EDT)
Received: by iedm5 with SMTP id m5so33298671ied.3
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 09:58:25 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id nb8si5107966icb.88.2015.03.20.09.58.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Mar 2015 09:58:25 -0700 (PDT)
Received: by igcqo1 with SMTP id qo1so23576216igc.0
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 09:58:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <550C5078.8040402@oracle.com>
References: <550C37C9.2060200@oracle.com>
	<CA+55aFxhNphSMrNvwqj0AQRzuqRdPG11J6DaazKWMb2U+H7wKg@mail.gmail.com>
	<550C5078.8040402@oracle.com>
Date: Fri, 20 Mar 2015 09:58:25 -0700
Message-ID: <CA+55aFyQWa0PjT-3y-HB9P-UAzThrZme5gj1P6P6hMTTF9cMtA@mail.gmail.com>
Subject: Re: 4.0.0-rc4: panic in free_block
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Ahern <david.ahern@oracle.com>
Cc: "David S. Miller" <davem@davemloft.net>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, sparclinux@vger.kernel.org

On Fri, Mar 20, 2015 at 9:53 AM, David Ahern <david.ahern@oracle.com> wrote:
>
> I haven't tried 3.19 yet. Just backed up to 3.18 and it shows the same
> problem. And I can reproduce the 4.0 crash in a 128 cpu ldom (VM).

Ok, so if 3.18 also has it, then trying 3.19 is pointless, this is
obviously an old problem. Which makes it even more likely that it's
sparc-related.

128 cpu's is still "unusual", of course, but by no means unheard of,
and I'f have expected others to report it too if it was wasy to
trigger on x86-64.

That said, SLAB is probably also almost unheard of in high-CPU
configurations, since slub has all the magical unlocked lists etc for
scalability. So maybe it's a generic SLAB bug, and nobody with lots of
CPU's is testing SLAB.

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
