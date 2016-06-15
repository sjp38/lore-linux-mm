Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 211426B0261
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 16:26:50 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id l5so66836366ioa.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 13:26:50 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id zd7si904060pac.177.2016.06.15.13.26.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 13:26:49 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id hf6so2133513pac.2
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 13:26:49 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2] Linux VM workaround for Knights Landing A/D leak
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <5761B630.7020502@linux.intel.com>
Date: Wed, 15 Jun 2016 13:26:46 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <E0403A01-57FD-4232-879F-4AF14873C57E@gmail.com>
References: <7FB15233-B347-4A87-9506-A9E10D331292@gmail.com> <1465923672-14232-1-git-send-email-lukasz.anaczkowski@intel.com> <76F6D5F2-6723-441B-BD63-52628731F1FF@gmail.com> <C1C2579D7BE026428F81F41198ADB17237A8670A@irsmsx110.ger.corp.intel.com> <613007E2-2A88-4934-9364-A5A66A555305@gmail.com> <5761B630.7020502@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, "Srinivasappa, Harish" <harish.srinivasappa@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Andrejczuk, Grzegorz" <grzegorz.andrejczuk@intel.com>, "Daniluk, Lukasz" <lukasz.daniluk@intel.com>

Dave Hansen <dave.hansen@linux.intel.com> wrote:

> On 06/15/2016 01:04 PM, Nadav Amit wrote:
>> Be careful here. According to the SDM when invalidating a huge-page,
>> each 4KB page needs to be invalidated separately. In practice, when
>> Linux invalidates 2MB/1GB pages it performs a full TLB flush. The
>> full flush may not be required on knights landing, and specifically
>> for the workaround, but you should check. =20
>=20
> Where do you get that?  The SDM says: "they (TLB invalidation =
operations
> invalidate all TLB entries corresponding to the translation specified =
by
> the paging structures.=94

You are absolutely correct. Last time I write something based on my
recollection of the SDM without re-reading again. Sorry.

Nadav

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
