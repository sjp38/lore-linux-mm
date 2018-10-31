Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B7A296B000D
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 17:23:46 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 127-v6so12589262pgb.7
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 14:23:46 -0700 (PDT)
Received: from giraffe.birch.relay.mailchannels.net (giraffe.birch.relay.mailchannels.net. [23.83.209.69])
        by mx.google.com with ESMTPS id g3-v6si27974044pgj.74.2018.10.31.14.23.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 14:23:44 -0700 (PDT)
From: Tulio Magno Quites Machado Filho <tuliom@ascii.art.br>
Subject: Re: PIE binaries are no longer mapped below 4 GiB on ppc64le
In-Reply-To: <877ehyf1cj.fsf@oldenburg.str.redhat.com>
References: <87k1lyf2x3.fsf@oldenburg.str.redhat.com> <20181031185032.679e170a@naga.suse.cz> <877ehyf1cj.fsf@oldenburg.str.redhat.com>
Date: Wed, 31 Oct 2018 18:23:37 -0300
Message-ID: <87efc5n73a.fsf@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>, Michal =?utf-8?Q?Such=C3=A1nek?= <msuchanek@suse.de>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Lynn A. Boger" <laboger@linux.ibm.com>

Florian Weimer <fweimer@redhat.com> writes:

> * Michal Such=C3=A1nek:
>
>> On Wed, 31 Oct 2018 18:20:56 +0100
>> Florian Weimer <fweimer@redhat.com> wrote:
>>
>>> And it needs to be built with:
>>>=20
>>>   go build -ldflags=3D-extldflags=3D-pie extld.go
>>>=20
>>> I'm not entirely sure what to make of this, but I'm worried that this
>>> could be a regression that matters to userspace.
>>
>> I encountered the same when trying to build go on ppc64le. I am not
>> familiar with the internals so I just let it be.
>>
>> It does not seem to matter to any other userspace.
>
> It would matter to C code which returns the address of a global variable
> in the main program through and (implicit) int return value.

I wonder if this is restricted to linker that Golang uses.
Were you able to reproduce the same problem with Binutils' linker?

--=20
Tulio Magno
