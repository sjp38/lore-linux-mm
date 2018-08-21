Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7C6C46B1D54
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 02:40:19 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id p5-v6so9149071pfh.11
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 23:40:19 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id k193-v6si7070824pge.4.2018.08.20.23.40.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 20 Aug 2018 23:40:18 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: Odd SIGSEGV issue introduced by commit 6b31d5955cb29 ("mm, oom: fix potential data corruption when oom_reaper races with writer")
In-Reply-To: <7767bdf4-a034-ecb9-1ac8-4fa87f335818@c-s.fr>
References: <7767bdf4-a034-ecb9-1ac8-4fa87f335818@c-s.fr>
Date: Tue, 21 Aug 2018 16:40:15 +1000
Message-ID: <871sasmddc.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe LEROY <christophe.leroy@c-s.fr>, Michal Hocko <mhocko@kernel.org>, Ram Pai <linuxram@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, linux-mm <linux-mm@kvack.org>

Christophe LEROY <christophe.leroy@c-s.fr> writes:
...
>
> And I bisected its disappearance with commit 99cd1302327a2 ("powerpc: 
> Deliver SEGV signal on pkey violation")

Whoa that's weird.

> Looking at those two commits, especially the one which makes it 
> dissapear, I'm quite sceptic. Any idea on what could be the cause and/or 
> how to investigate further ?

Are you sure it's not some corruption that just happens to be masked by
that commit? I can't see anything in that commit that could explain that
change in behaviour.

The only real change is if you're hitting DSISR_KEYFAULT isn't it?

What happens if you take 087003e9ef7c and apply the various hunks from
99cd1302327a2 gradually (or those that you can anyway)?

cheers
