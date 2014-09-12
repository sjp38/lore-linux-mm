Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id D2F326B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 23:10:41 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id y13so233574pdi.7
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 20:10:41 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id qb9si4880765pbb.256.2014.09.11.20.10.40
        for <linux-mm@kvack.org>;
        Thu, 11 Sep 2014 20:10:40 -0700 (PDT)
From: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Subject: RE: [PATCH v8 08/10] x86, mpx: add prctl commands PR_MPX_REGISTER,
 PR_MPX_UNREGISTER
Date: Fri, 12 Sep 2014 03:10:37 +0000
Message-ID: <9E0BE1322F2F2246BD820DA9FC397ADE017A403C@shsmsx102.ccr.corp.intel.com>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
 <1410425210-24789-9-git-send-email-qiaowei.ren@intel.com>
 <5411B9BD.2000900@intel.com>
In-Reply-To: <5411B9BD.2000900@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>



On 2014-09-11, Hansen, Dave wrote:
> On 09/11/2014 01:46 AM, Qiaowei Ren wrote:
>> +
>> +	return (void __user *)(unsigned long)(xsave_buf->bndcsr.cfg_reg_u &
>> +			MPX_BNDCFG_ADDR_MASK);
>> +}
>=20
> I don't think casting a u64 to a ulong, then to a pointer is useful.
> Just take the '(unsigned long)' out.

If so, this will spits out a warning on 32-bit:

arch/x86/kernel/mpx.c: In function 'task_get_bounds_dir':
arch/x86/kernel/mpx.c:21:9: warning: cast to pointer from integer of differ=
ent size [-Wint-to-pointer-cast]

Thanks,
Qiaowei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
