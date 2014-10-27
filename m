Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 593236B0069
	for <linux-mm@kvack.org>; Sun, 26 Oct 2014 21:45:54 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id r10so4664804pdi.31
        for <linux-mm@kvack.org>; Sun, 26 Oct 2014 18:45:54 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id j5si9353014pdk.48.2014.10.26.18.45.52
        for <linux-mm@kvack.org>;
        Sun, 26 Oct 2014 18:45:53 -0700 (PDT)
From: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Subject: RE: [PATCH v9 09/12] x86, mpx: decode MPX instruction to get bound
 violation information
Date: Mon, 27 Oct 2014 01:43:00 +0000
Message-ID: <9E0BE1322F2F2246BD820DA9FC397ADE0180ED16@shsmsx102.ccr.corp.intel.com>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com>
 <1413088915-13428-10-git-send-email-qiaowei.ren@intel.com>
 <alpine.DEB.2.11.1410241408360.5308@nanos>
In-Reply-To: <alpine.DEB.2.11.1410241408360.5308@nanos>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>



On 2014-10-24, Thomas Gleixner wrote:
> On Sun, 12 Oct 2014, Qiaowei Ren wrote:
>=20
>> This patch sets bound violation fields of siginfo struct in #BR
>> exception handler by decoding the user instruction and constructing
>> the faulting pointer.
>>=20
>> This patch does't use the generic decoder, and implements a limited
>> special-purpose decoder to decode MPX instructions, simply because
>> the generic decoder is very heavyweight not just in terms of
>> performance but in terms of interface -- because it has to.
>=20
> My question still stands why using the existing decoder is an issue.
> Performance is a complete non issue in case of a bounds violation and
> the interface argument is just silly, really.
>=20

As hpa said, we only need to decode several mpx instructions including BNDC=
L/BNDCU, and general decoder looks like a little heavy. Peter, what do you =
think about it?

Thanks,
Qiaowei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
