Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id AF8826B0038
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 17:09:24 -0400 (EDT)
Received: by oibu204 with SMTP id u204so49144721oib.0
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 14:09:24 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id q1si6257485oed.4.2015.03.16.14.09.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 14:09:23 -0700 (PDT)
From: "Kani, Toshimitsu" <toshi.kani@hp.com>
Subject: Re: [PATCH v3 3/5] mtrr, x86: Fix MTRR state checks in
 mtrr_type_lookup()
Date: Mon, 16 Mar 2015 21:08:16 +0000
Message-ID: <06AEC393-4271-46BB-913E-4909C3ED0C08@hp.com>
References: <1426282421-25385-1-git-send-email-toshi.kani@hp.com>
 <1426282421-25385-4-git-send-email-toshi.kani@hp.com>,<20150316075139.GB15955@gmail.com>
In-Reply-To: <20150316075139.GB15955@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "Elliott, Robert (Server
 Storage)" <Elliott@hp.com>, "pebolle@tiscali.nl" <pebolle@tiscali.nl>

> On Mar 16, 2015, at 3:51 AM, Ingo Molnar <mingo@kernel.org> wrote:
>=20
>=20
> * Toshi Kani <toshi.kani@hp.com> wrote:
>=20
>> 'mtrr_state.enabled' contains FE (fixed MTRRs enabled) and
>> E (MTRRs enabled) flags in MSR_MTRRdefType.  Intel SDM,
>> section 11.11.2.1, defines these flags as follows:
>> - All MTRRs are disabled when the E flag is clear.
>>   The FE flag has no affect when the E flag is clear.
>> - The default type is enabled when the E flag is set.
>> - MTRR variable ranges are enabled when the E flag is set.
>> - MTRR fixed ranges are enabled when both E and FE flags
>>   are set.
>>=20
>> MTRR state checks in __mtrr_type_lookup() do not follow the
>> SDM definitions.  Therefore, this patch fixes the MTRR state
>> checks according to the SDM.  This patch defines the flags
>> in mtrr_state.enabled as follows.  print_mtrr_state() is also
>> updated.
>> - FE flag: MTRR_STATE_MTRR_FIXED_ENABLED
>> - E  flag: MTRR_STATE_MTRR_ENABLED
>>=20
>> Lastly, this patch fixes the 'else if (start < 0x1000000)',
>> which checks a fixed range but has an extra-zero in the
>> address, to 'else' with no condition.
>=20
> Firstly, this does multiple bug fixes in a single patch, which is a=20
> no-no: please split it up into separate patches.

Right.  I will split into two patches.

> Secondly, please also outline the differences between the old code and=20
> the new code - don't just list the SDM logic and state that we are=20
> updating to it.

Yes, I will update the patch log accordingly.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
