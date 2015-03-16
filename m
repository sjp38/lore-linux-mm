Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 553966B0038
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 17:05:00 -0400 (EDT)
Received: by oier21 with SMTP id r21so49086172oie.1
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 14:05:00 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id os8si6233661oeb.103.2015.03.16.14.04.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 14:04:59 -0700 (PDT)
From: "Kani, Toshimitsu" <toshi.kani@hp.com>
Subject: Re: [PATCH v3 2/5] mtrr, x86: Fix MTRR lookup to handle inclusive
 entry
Date: Mon, 16 Mar 2015 21:03:52 +0000
Message-ID: <B75F1944-155A-4DAF-9382-A2E5596E9E19@hp.com>
References: <1426282421-25385-1-git-send-email-toshi.kani@hp.com>
 <1426282421-25385-3-git-send-email-toshi.kani@hp.com>,<20150316074954.GA15955@gmail.com>
In-Reply-To: <20150316074954.GA15955@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "Elliott, Robert (Server
 Storage)" <Elliott@hp.com>, "pebolle@tiscali.nl" <pebolle@tiscali.nl>

> On Mar 16, 2015, at 3:50 AM, Ingo Molnar <mingo@kernel.org> wrote:
>=20
>=20
> * Toshi Kani <toshi.kani@hp.com> wrote:
>=20
>> When an MTRR entry is inclusive to a requested range, i.e.
>> the start and end of the request are not within the MTRR
>> entry range but the range contains the MTRR entry entirely,
>> __mtrr_type_lookup() ignores such a case because both
>> start_state and end_state are set to zero.
>>=20
>> This patch fixes the issue by adding a new flag, 'inclusive',
>> to detect the case.  This case is then handled in the same
>> way as (!start_state && end_state).
>=20
> It would be nice to discuss the high level effects of this fix in the=20
> changelog: i.e. what (presumably bad thing) happened before the=20
> change, what will happen after the change? What did users experience=20
> before the patch, and what will users experience after the patch?

The original code uses this function to track=20
memory attributes of ioremap'd ranges=20
in order to avoid
any aliasing.
So, ignoring MTRR entries leads a tracked=20
memory attribute different from its effective=20
memory attribute.  I will document more=20
details in the next version.

I will update the patchset next week.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
