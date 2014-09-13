Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 521A26B0035
	for <linux-mm@kvack.org>; Sat, 13 Sep 2014 03:13:07 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lj1so2870766pab.27
        for <linux-mm@kvack.org>; Sat, 13 Sep 2014 00:13:07 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id pd9si12158440pac.49.2014.09.13.00.13.05
        for <linux-mm@kvack.org>;
        Sat, 13 Sep 2014 00:13:06 -0700 (PDT)
From: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Subject: RE: [PATCH v8 06/10] mips: sync struct siginfo with general version
Date: Sat, 13 Sep 2014 07:13:02 +0000
Message-ID: <9E0BE1322F2F2246BD820DA9FC397ADE017A5800@shsmsx102.ccr.corp.intel.com>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
 <1410425210-24789-7-git-send-email-qiaowei.ren@intel.com>
 <alpine.DEB.2.10.1409120007550.4178@nanos>
 <9E0BE1322F2F2246BD820DA9FC397ADE017A3FF0@shsmsx102.ccr.corp.intel.com>
 <alpine.DEB.2.10.1409121015070.4178@nanos>
In-Reply-To: <alpine.DEB.2.10.1409121015070.4178@nanos>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>



On 2014-09-12, Thomas Gleixner wrote:
> On Fri, 12 Sep 2014, Ren, Qiaowei wrote:
>> On 2014-09-12, Thomas Gleixner wrote:
>>> On Thu, 11 Sep 2014, Qiaowei Ren wrote:
>>>=20
>>>> Due to new fields about bound violation added into struct
>>>> siginfo, this patch syncs it with general version to avoid build issue=
.
>>>=20
>>> You completely fail to explain which build issue is addressed by
>>> this patch. The code you added to kernel/signal.c which accesses
>>> _addr_bnd is guarded by
>>>=20
>>> +#ifdef SEGV_BNDERR
>>>=20
>>> which is not defined my MIPS. Also why is this only affecting MIPS
>>> and not any other architecture which provides its own struct siginfo ?
>>>=20
>>> That patch makes no sense at all, at least not without a proper explana=
tion.
>>>=20
>> For arch=3Dmips, siginfo.h (arch/mips/include/uapi/asm/siginfo.h) will
>> include general siginfo.h, and only replace general stuct siginfo
>> with mips specific struct siginfo. So SEGV_BNDERR will be defined
>> for all archs, and we will get error like "no _lower in struct
>> siginfo" when arch=3Dmips.
>>=20
>> In addition, only MIPS arch define its own struct siginfo, so this
>> is only affecting MIPS.
>=20
> So IA64 does not count as an architecture and therefor does not need
> the same treatment, right?
>=20
struct siginfo for IA64 should be also synced. I will do this next post.

Thanks,
Qiaowei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
