Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id C99126B0035
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 20:57:09 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so2777538pad.11
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 17:57:09 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ip4si4149753pbd.223.2014.07.23.17.57.08
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 17:57:08 -0700 (PDT)
From: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Subject: RE: [PATCH v7 03/10] x86, mpx: add macro cpu_has_mpx
Date: Thu, 24 Jul 2014 00:56:36 +0000
Message-ID: <9E0BE1322F2F2246BD820DA9FC397ADE01703028@shsmsx102.ccr.corp.intel.com>
References: <1405921124-4230-1-git-send-email-qiaowei.ren@intel.com>
 <1405921124-4230-4-git-send-email-qiaowei.ren@intel.com>
 <53CE8EEC.2090402@intel.com>
 <9E0BE1322F2F2246BD820DA9FC397ADE0170079E@shsmsx102.ccr.corp.intel.com>
 <53CFDC79.8040804@intel.com>
In-Reply-To: <53CFDC79.8040804@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>



On 2014-07-24, Hansen, Dave wrote:
> On 07/22/2014 07:35 PM, Ren, Qiaowei wrote:
>> The checking about MPX feature should be as follow:
>>=20
>>         if (pcntxt_mask & XSTATE_EAGER) {
>>                 if (eagerfpu =3D=3D DISABLE) {
>>                         pr_err("eagerfpu not present, disabling some
> xstate features: 0x%llx\n",
>>                                         pcntxt_mask &
> XSTATE_EAGER);
>>                         pcntxt_mask &=3D ~XSTATE_EAGER; } else { eagerfp=
u
>>                         =3D ENABLE;
>>                 }
>>         }
>> This patch was merged into kernel the ending of last year
>> (https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/com
>> mi
>> t/?id=3De7d820a5e549b3eb6c3f9467507566565646a669 )
>=20
> Should we be doing a clear_cpu_cap(X86_FEATURE_MPX) in here?
>=20
> This isn't major, but I can't _ever_ imagine a user being able to
> track down why MPX is not working from this message.  Should we spruce it=
 up somehow?

Maybe. If the error log "disabling some xstate features:" is changed to "di=
sabling MPX xstate features:", do you think it is OK?

Thanks,
Qiaowei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
