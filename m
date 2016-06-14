Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4743C6B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 12:54:35 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ao6so261275221pac.2
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 09:54:35 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id c1si1949616paz.112.2016.06.14.09.54.34
        for <linux-mm@kvack.org>;
        Tue, 14 Jun 2016 09:54:34 -0700 (PDT)
From: "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>
Subject: RE: [PATCH] Linux VM workaround for Knights Landing A/D leak
Date: Tue, 14 Jun 2016 16:54:30 +0000
Message-ID: <C1C2579D7BE026428F81F41198ADB17237A857BF@irsmsx110.ger.corp.intel.com>
References: <1465919919-2093-1-git-send-email-lukasz.anaczkowski@intel.com>
 <7FB15233-B347-4A87-9506-A9E10D331292@gmail.com>
In-Reply-To: <7FB15233-B347-4A87-9506-A9E10D331292@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, "Srinivasappa, Harish" <harish.srinivasappa@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>

From: Nadav Amit [mailto:nadav.amit@gmail.com]=20
Sent: Tuesday, June 14, 2016 6:48 PM

> Lukasz Anaczkowski <lukasz.anaczkowski@intel.com> wrote:

>> From: Andi Kleen <ak@linux.intel.com>
>> +void fix_pte_leak(struct mm_struct *mm, unsigned long addr, pte_t *ptep=
)
>> +{
> Here there should be a call to smp_mb__after_atomic() to synchronize with
> switch_mm. I submitted a similar patch, which is still pending (hint).

Thanks, Nadav!
I'll add this and re-submit the patch.

Cheers,
Lukasz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
