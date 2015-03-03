Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 32F3C6B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 04:28:44 -0500 (EST)
Received: by qcxr5 with SMTP id r5so29312703qcx.10
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 01:28:44 -0800 (PST)
Received: from service87.mimecast.com (service87.mimecast.com. [91.220.42.44])
        by mx.google.com with ESMTP id h34si193964qgf.2.2015.03.03.01.28.43
        for <linux-mm@kvack.org>;
        Tue, 03 Mar 2015 01:28:43 -0800 (PST)
Message-ID: <54F57EC7.1060202@arm.com>
Date: Tue, 03 Mar 2015 09:28:39 +0000
From: Vladimir Murzin <vladimir.murzin@arm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/4] make memtest a generic kernel feature
References: <1425308145-20769-1-git-send-email-vladimir.murzin@arm.com> <20150302151400.GI15668@tarshish>
In-Reply-To: <20150302151400.GI15668@tarshish>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baruch Siach <baruch@tkos.co.il>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Mark Rutland <Mark.Rutland@arm.com>, "lauraa@codeaurora.org" <lauraa@codeaurora.org>, "arnd@arndb.de" <arnd@arndb.de>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <Will.Deacon@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "tglx@linutronix.de" <tglx@linutronix.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On 02/03/15 15:14, Baruch Siach wrote:
> Hi Vladimir,
>=20
> On Mon, Mar 02, 2015 at 02:55:41PM +0000, Vladimir Murzin wrote:
>> Memtest is a simple feature which fills the memory with a given set of
>> patterns and validates memory contents, if bad memory regions is detecte=
d it
>> reserves them via memblock API. Since memblock API is widely used by oth=
er
>> architectures this feature can be enabled outside of x86 world.
>>
>> This patch set promotes memtest to live under generic mm umbrella and en=
ables
>> memtest feature for arm/arm64.
>=20
> Please update the architectures list in the 'memtest' entry at=20
> Documentation/kernel-parameters.txt.

Thanks for pointing at it. I'll add updates for documentation to my next
version.

Vladimir

>=20
> baruch
>=20


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
