Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 248786B0005
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 09:13:12 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id b13so28979162pat.3
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 06:13:12 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id x194si40986657pfd.200.2016.06.15.06.13.03
        for <linux-mm@kvack.org>;
        Wed, 15 Jun 2016 06:13:09 -0700 (PDT)
From: "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>
Subject: RE: [PATCH v2] Linux VM workaround for Knights Landing A/D leak
Date: Wed, 15 Jun 2016 13:12:59 +0000
Message-ID: <C1C2579D7BE026428F81F41198ADB17237A8670A@irsmsx110.ger.corp.intel.com>
References: <7FB15233-B347-4A87-9506-A9E10D331292@gmail.com>
 <1465923672-14232-1-git-send-email-lukasz.anaczkowski@intel.com>
 <76F6D5F2-6723-441B-BD63-52628731F1FF@gmail.com>
In-Reply-To: <76F6D5F2-6723-441B-BD63-52628731F1FF@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, "Srinivasappa, Harish" <harish.srinivasappa@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Andrejczuk, Grzegorz" <grzegorz.andrejczuk@intel.com>, "Daniluk, Lukasz" <lukasz.daniluk@intel.com>

From: Nadav Amit [mailto:nadav.amit@gmail.com]=20
Sent: Tuesday, June 14, 2016 8:38 PM

>> +	pte_t pte =3D ptep_get_and_clear(mm, addr, ptep);
>> +
>> +	if (boot_cpu_has_bug(X86_BUG_PTE_LEAK))
>> +		fix_pte_leak(mm, addr, ptep);
>> +	return pte;
>> }
>
> I missed it on the previous iteration: ptep_get_and_clear already calls=20
> fix_pte_leak when needed. So do you need to call it again here?

You're right, Nadav. Not needing this. Will be removed in next version of t=
he patch.

Cheers,
Lukasz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
