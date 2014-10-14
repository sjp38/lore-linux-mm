Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0AE6B0069
	for <linux-mm@kvack.org>; Mon, 13 Oct 2014 21:44:21 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so6863855pad.36
        for <linux-mm@kvack.org>; Mon, 13 Oct 2014 18:44:20 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id gn1si11652033pbd.58.2014.10.13.18.44.19
        for <linux-mm@kvack.org>;
        Mon, 13 Oct 2014 18:44:19 -0700 (PDT)
From: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Subject: RE: [PATCH v7 08/10] x86, mpx: add prctl commands PR_MPX_REGISTER,
 PR_MPX_UNREGISTER
Date: Tue, 14 Oct 2014 01:44:16 +0000
Message-ID: <9E0BE1322F2F2246BD820DA9FC397ADE017EB405@shsmsx102.ccr.corp.intel.com>
References: <1405921124-4230-1-git-send-email-qiaowei.ren@intel.com>
	<1405921124-4230-9-git-send-email-qiaowei.ren@intel.com>
 <87lhrn2qfu.fsf@tassilo.jf.intel.com> <543C0EBE.3060702@intel.com>
In-Reply-To: <543C0EBE.3060702@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>



On 2014-10-14, Hansen, Dave wrote:
> On 07/20/2014 11:09 PM, Andi Kleen wrote:
>> Qiaowei Ren <qiaowei.ren@intel.com> writes:
>>> This patch adds the PR_MPX_REGISTER and PR_MPX_UNREGISTER prctl()
>>> commands. These commands can be used to register and unregister MPX
>>> related resource on the x86 platform.
>>=20
>> Please provide a manpage for the API. This is needed for proper
>> review. Your description is far too vague.
>=20
> Qiaowei, have you written this manpage yet?  I see the new patches,
> but no manpage yet.

It will be added into subsequent version or another mainline patchset.

Thanks,
Qiaowei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
