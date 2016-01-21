Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2B2A96B0005
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 00:11:15 -0500 (EST)
Received: by mail-io0-f176.google.com with SMTP id 1so43169940ion.1
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 21:11:15 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id c18si47974801igr.73.2016.01.20.21.11.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 21:11:14 -0800 (PST)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v2] mm: make apply_to_page_range more robust
In-Reply-To: <alpine.DEB.2.10.1601201536040.18155@chino.kir.corp.google.com>
References: <569F184D.8020602@nextfour.com> <alpine.DEB.2.10.1601201536040.18155@chino.kir.corp.google.com>
Date: Thu, 21 Jan 2016 15:28:18 +1030
Message-ID: <87egdby1ed.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Mika =?utf-8?Q?Penttil=C3=A4?= <mika.penttila@nextfour.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>

David Rientjes <rientjes@google.com> writes:
> On Wed, 20 Jan 2016, Mika Penttil=C3=A4 wrote:
>
>> Recent changes (4.4.0+) in module loader triggered oops on ARM.=20
>>=20=20=20=20=20
>> can be 0 triggering the bug  BUG_ON(addr >=3D end);.
>>=20
>> The call path is SyS_init_module()->set_memory_xx()->apply_to_page_range=
(),
>> and apply_to_page_range gets zero length resulting in triggering :
>>=20=20=20=20
>>   BUG_ON(addr >=3D end)
>>=20
>> This is a consequence of changes in module section handling (Rusty CC:ed=
).
>> This may be triggable only with certain modules and/or gcc versions.=20
>>=20
>
> Well, what module are you loading to cause this crash?  Why would it be=20
> passing size =3D=3D 0 to apply_to_page_range()?  Again, that sounds like =
a=20
> problem that we _want_ to know about since it is probably the result of=20
> buggy code and this patch would be covering it up.

Yes, I'm curious too.  It's certainly possible, since I expected a
zero-length range to do nothing, but let's make sure we're not papering
over some other screwup of mine.

Thanks,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
