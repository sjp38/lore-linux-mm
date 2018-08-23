Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7F26B2759
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 21:26:03 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d132-v6so1972966pgc.22
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 18:26:03 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id h37-v6si3044185pgi.186.2018.08.22.18.26.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 22 Aug 2018 18:26:01 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: Odd SIGSEGV issue introduced by commit 6b31d5955cb29 ("mm, oom: fix potential data corruption when oom_reaper races with writer")
In-Reply-To: <7767bdf4-a034-ecb9-1ac8-4fa87f335818@c-s.fr>
References: <7767bdf4-a034-ecb9-1ac8-4fa87f335818@c-s.fr>
Date: Thu, 23 Aug 2018 11:25:56 +1000
Message-ID: <87o9dtlvq3.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe LEROY <christophe.leroy@c-s.fr>, Michal Hocko <mhocko@kernel.org>, Ram Pai <linuxram@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, linux-mm <linux-mm@kvack.org>

Christophe LEROY <christophe.leroy@c-s.fr> writes:
> Hello,
>
> I have an odd issue on my powerpc 8xx board.
>
> I am running latest 4.14 and get the following SIGSEGV which appears 
> more or less randomly.
>
> [    9.190354] touch[91]: unhandled signal 11 at 67807b58 nip 777cf114 
> lr 777cf100 code 30001
> [   24.634810] ifconfig[160]: unhandled signal 11 at 67ae7b58 nip 
> 77aaf114 lr 77aaf100 code 30001


It would be interesting to see the code dump here and which registers
are being used.

Can you backport the show unhandled signal changes and see what that
shows us?

cheers
