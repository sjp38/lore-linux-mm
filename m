Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id AFCE26B02F3
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 19:32:19 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 41so72749096iop.2
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 16:32:19 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id w70si2587416pgw.626.2017.08.17.16.32.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 16:32:18 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH-resend] mm/hwpoison: Clear PRESENT bit for kernel 1:1
 mappings of poison pages
Date: Thu, 17 Aug 2017 23:32:16 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F61342363@ORSMSX114.amr.corp.intel.com>
References: <CAPcyv4gC_6TpwVSjuOzxrz3OdVZCVWD0QVWhBzAuOxUNHJHRMQ@mail.gmail.com>
	<20170816171803.28342-1-tony.luck@intel.com>
 <20170817150942.017f87537b6cbb48e9cfc082@linux-foundation.org>
In-Reply-To: <20170817150942.017f87537b6cbb48e9cfc082@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Borislav Petkov <bp@suse.de>, "Hansen, Dave" <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Elliott, Robert (Persistent
 Memory)" <elliott@hpe.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> It's unclear (to lil ole me) what the end-user-visible effects of this
> are.
>
> Could we please have a description of that?  So a) people can
> understand your decision to cc:stable and b) people whose kernels are
> misbehaving can use your description to decide whether your patch might
> fix the issue their users are reporting.

Ingo already applied this to the tip tree, so too late to fix the commit me=
ssage :-(

A very, very, unlucky end user with a system that supports machine check re=
covery
(Xeon E7, or Xeon-SP-platinum) that has recovered from one or more uncorrec=
ted
memory errors (lucky so far) might find a subsequent uncorrected memory err=
or flagged
as fatal because the machine check bank that should log the error is alread=
y occupied
by a log caused by a speculative access to one of the earlier uncorrected e=
rrors (the
unlucky part).

We haven't seen this happen at the Linux OS level, but it is a theoretical =
possibility.
[Some BIOS that map physical memory 1:1 have seen this when doing eMCA proc=
essing
for the first error ... as soon as they load the address of the error from =
the MCi_ADDR
register they are vulnerable to some speculative access dereferencing the r=
egister with=20
the address and setting the overflow bit in the machine check bank that sti=
ll holds the
original log].

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
