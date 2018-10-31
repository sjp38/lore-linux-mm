Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 84B786B0269
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 17:28:54 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id h4-v6so17844356qtp.7
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 14:28:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y1si1553446qta.312.2018.10.31.14.28.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 14:28:53 -0700 (PDT)
From: Florian Weimer <fweimer@redhat.com>
Subject: Re: PIE binaries are no longer mapped below 4 GiB on ppc64le
References: <87k1lyf2x3.fsf@oldenburg.str.redhat.com>
	<20181031185032.679e170a@naga.suse.cz>
	<877ehyf1cj.fsf@oldenburg.str.redhat.com>
	<87efc5n73a.fsf@linux.ibm.com>
Date: Wed, 31 Oct 2018 22:28:48 +0100
In-Reply-To: <87efc5n73a.fsf@linux.ibm.com> (Tulio Magno Quites Machado
	Filho's message of "Wed, 31 Oct 2018 18:23:37 -0300")
Message-ID: <87in1hlsa7.fsf@oldenburg.str.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tulio Magno Quites Machado Filho <tuliom@ascii.art.br>
Cc: Michal =?utf-8?Q?Such=C3=A1nek?= <msuchanek@suse.de>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Lynn A. Boger" <laboger@linux.ibm.com>

* Tulio Magno Quites Machado Filho:

> Florian Weimer <fweimer@redhat.com> writes:
>
>> * Michal Such=C3=A1nek:
>>
>>> On Wed, 31 Oct 2018 18:20:56 +0100
>>> Florian Weimer <fweimer@redhat.com> wrote:
>>>
>>>> And it needs to be built with:
>>>>=20
>>>>   go build -ldflags=3D-extldflags=3D-pie extld.go
>>>>=20
>>>> I'm not entirely sure what to make of this, but I'm worried that this
>>>> could be a regression that matters to userspace.
>>>
>>> I encountered the same when trying to build go on ppc64le. I am not
>>> familiar with the internals so I just let it be.
>>>
>>> It does not seem to matter to any other userspace.
>>
>> It would matter to C code which returns the address of a global variable
>> in the main program through and (implicit) int return value.
>
> I wonder if this is restricted to linker that Golang uses.
> Were you able to reproduce the same problem with Binutils' linker?

The example is carefully constructed to use the external linker.  It
invokes gcc, which then invokes the BFD linker in my case.

Based on the relocations, I assume there is only so much the linker can
do here.  I'm amazed that it produces an executable at all, let alone
one that runs correctly on some kernel versions!  I assume that the Go
toolchain simply lacks PIE support on ppc64le.

Thanks,
Florian
