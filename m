Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id EB6196B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 04:27:03 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id a108so21829262qge.8
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 01:27:03 -0800 (PST)
Received: from service87.mimecast.com (service87.mimecast.com. [91.220.42.44])
        by mx.google.com with ESMTP id i204si150368qhc.58.2015.03.03.01.27.02
        for <linux-mm@kvack.org>;
        Tue, 03 Mar 2015 01:27:03 -0800 (PST)
Message-ID: <54F57E62.6050206@arm.com>
Date: Tue, 03 Mar 2015 09:26:58 +0000
From: Vladimir Murzin <vladimir.murzin@arm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 3/4] arm64: add support for memtest
References: <1425308145-20769-1-git-send-email-vladimir.murzin@arm.com> <1425308145-20769-4-git-send-email-vladimir.murzin@arm.com> <20150302185607.GG7919@arm.com>
In-Reply-To: <20150302185607.GG7919@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "lauraa@codeaurora.org" <lauraa@codeaurora.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "arnd@arndb.de" <arnd@arndb.de>, Mark Rutland <Mark.Rutland@arm.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>

On 02/03/15 18:56, Will Deacon wrote:
> On Mon, Mar 02, 2015 at 02:55:44PM +0000, Vladimir Murzin wrote:
>> Add support for memtest command line option.
>>
>> Signed-off-by: Vladimir Murzin <vladimir.murzin@arm.com>
>> ---
>>  arch/arm64/mm/init.c |    2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
>> index ae85da6..597831b 100644
>> --- a/arch/arm64/mm/init.c
>> +++ b/arch/arm64/mm/init.c
>> @@ -190,6 +190,8 @@ void __init bootmem_init(void)
>>  =09min =3D PFN_UP(memblock_start_of_DRAM());
>>  =09max =3D PFN_DOWN(memblock_end_of_DRAM());
>> =20
>> +=09early_memtest(min << PAGE_SHIFT, max << PAGE_SHIFT);
>> +
>>  =09/*
>>  =09 * Sparsemem tries to allocate bootmem in memory_present(), so must =
be
>>  =09 * done after the fixed reservations.
>=20
> This is really neat, thanks for doing this Vladimir!
>=20
>   Acked-by: Will Deacon <will.deacon@arm.com>
>=20
> For the series, modulo Baruch's comments about Documentation updates.
>=20
> Will
>=20

Thanks Will! I'll wait for awhile for other comments and repost updated
version.

I wonder which tree it might go?

Thanks
Vladimir

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>=20
>=20


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
