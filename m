Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6AC5C6B00EA
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 17:24:44 -0400 (EDT)
Received: by vxg38 with SMTP id 38so1745779vxg.14
        for <linux-mm@kvack.org>; Wed, 29 Jun 2011 14:24:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=2ZMmrwMrnyEyEZAEsCUQNnd5n1j8J0xzSEF=ahrJmLw@mail.gmail.com>
References: <fa.fHPNPTsllvyE/7DxrKwiwgVbVww@ifi.uio.no>
	<532cc290-4b9c-4eb2-91d4-aa66c01bb3a0@glegroupsg2000goo.googlegroups.com>
	<BANLkTik3mEJGXLrf_XtssfdRypm3NxBKvkhcnUpK=YXV6ux=Ag@mail.gmail.com>
	<20110629080827.GA975@phantom.vanrein.org>
	<BANLkTikw9bnrurUo8n-6yUwwQ0zOv5iAOBDt=T6Nm6nkUd7vLA@mail.gmail.com>
	<BANLkTi=2ZMmrwMrnyEyEZAEsCUQNnd5n1j8J0xzSEF=ahrJmLw@mail.gmail.com>
Date: Wed, 29 Jun 2011 14:24:41 -0700
Message-ID: <BANLkTinN0EOH=OMQ8idG7Xt5OufU-6Rn3A@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
From: Tony Luck <tony.luck@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Craig Bergstrom <craigb@google.com>
Cc: linux-kernel@vger.kernel.org, fa.linux.kernel@googlegroups.com, Rick van Rein <rick@vanrein.org>, "H. Peter Anvin" <hpa@zytor.com>, Stefan Assmann <sassmann@kpanic.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, "mingo@elte.hu" <mingo@elte.hu>, "rdunlap@xenotime.net" <rdunlap@xenotime.net>, Nancy Yuen <yuenn@google.com>, Michael Ditto <mditto@google.com>

One extra consideration for this whole proposal ...

Is the "physical address" a stable enough representation of the location
of the faulty memory cells?

On high end systems I can see a number of ways where the mapping
from cells to physical address may change across reboot:

1) System support redundant memory (rank sparing or mirroring)
2) BIOS self test removes some memory from use
3) A multi-node system elects a different node to be boot-meister,
which results in reshuffling of the address map.

If any of these can happen: then it doesn't matter whether we have
a list of addresses, or a pattern that expands to a list of addresses.
We'll still mark some innocent memory as bad, and allow some known
bad memory to be used - because our "addresses" no longer correspond
to the bad memory cells.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
