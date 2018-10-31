Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 98FE26B0003
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 18:04:25 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i81-v6so14827449pfj.1
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 15:04:25 -0700 (PDT)
Received: from catfish.maple.relay.mailchannels.net (catfish.maple.relay.mailchannels.net. [23.83.214.32])
        by mx.google.com with ESMTPS id m3si156264pgs.8.2018.10.31.15.04.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 15:04:24 -0700 (PDT)
From: Tulio Magno Quites Machado Filho <tuliom@ascii.art.br>
Subject: Re: PIE binaries are no longer mapped below 4 GiB on ppc64le
In-Reply-To: <87in1hlsa7.fsf@oldenburg.str.redhat.com>
References: <87k1lyf2x3.fsf@oldenburg.str.redhat.com> <20181031185032.679e170a@naga.suse.cz> <877ehyf1cj.fsf@oldenburg.str.redhat.com> <87efc5n73a.fsf@linux.ibm.com> <87in1hlsa7.fsf@oldenburg.str.redhat.com>
Date: Wed, 31 Oct 2018 19:04:14 -0300
Message-ID: <87bm79n57l.fsf@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Michal =?utf-8?Q?Such=C3=A1nek?= <msuchanek@suse.de>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Lynn A. Boger" <laboger@linux.ibm.com>

Florian Weimer <fweimer@redhat.com> writes:

> * Tulio Magno Quites Machado Filho:
>
>> I wonder if this is restricted to linker that Golang uses.
>> Were you able to reproduce the same problem with Binutils' linker?
>
> The example is carefully constructed to use the external linker.  It
> invokes gcc, which then invokes the BFD linker in my case.

Indeed. That question was unnecessary.  :-D

> Based on the relocations, I assume there is only so much the linker can
> do here.  I'm amazed that it produces an executable at all, let alone
> one that runs correctly on some kernel versions!

Agreed.  That isn't expected to work.  Both the compiler and the linker have
to generate PIE for it to work.

> I assume that the Go toolchain simply lacks PIE support on ppc64le.

Maybe the support is there, but it doesn't generate PIC by default?

-- 
Tulio Magno
