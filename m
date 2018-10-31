Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F3BE16B0003
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 13:50:35 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id z72-v6so1621983ede.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 10:50:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h1-v6si4477653ejd.261.2018.10.31.10.50.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 10:50:34 -0700 (PDT)
Date: Wed, 31 Oct 2018 18:50:32 +0100
From: Michal =?UTF-8?B?U3VjaMOhbmVr?= <msuchanek@suse.de>
Subject: Re: PIE binaries are no longer mapped below 4 GiB on ppc64le
Message-ID: <20181031185032.679e170a@naga.suse.cz>
In-Reply-To: <87k1lyf2x3.fsf@oldenburg.str.redhat.com>
References: <87k1lyf2x3.fsf@oldenburg.str.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Wed, 31 Oct 2018 18:20:56 +0100
Florian Weimer <fweimer@redhat.com> wrote:

> We tried to use Go to build PIE binaries, and while the Go toolchain
> is definitely not ready (it produces text relocations and problematic
> relocations in general), it exposed what could be an accidental
> userspace ABI change.
>=20
> With our 4.10-derived kernel, PIE binaries are mapped below 4 GiB, so
> relocations like R_PPC64_ADDR16_HA work:
>=20
...

> There are fewer mappings because the loader detects a relocation
> overflow and aborts (=E2=80=9Cerror while loading shared libraries:
> R_PPC64_ADDR16_HA reloc at 0x0000000120f0983c for symbol `' out of
> range=E2=80=9D), so I had to recover the mappings externally.  Disabling =
ASLR
> does not help.
>=20
...
>=20
> And it needs to be built with:
>=20
>   go build -ldflags=3D-extldflags=3D-pie extld.go
>=20
> I'm not entirely sure what to make of this, but I'm worried that this
> could be a regression that matters to userspace.

I encountered the same when trying to build go on ppc64le. I am not
familiar with the internals so I just let it be.

It does not seem to matter to any other userspace. Maybe it would be
good idea to generate 64bit relocations on 64bit targets?

Thanks

Michal
