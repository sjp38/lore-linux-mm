Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 97F486B0037
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 02:11:29 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so8610556pdj.30
        for <linux-mm@kvack.org>; Sun, 20 Jul 2014 23:11:29 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id km1si13137656pbd.126.2014.07.20.23.11.28
        for <linux-mm@kvack.org>;
        Sun, 20 Jul 2014 23:11:28 -0700 (PDT)
From: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Subject: RE: [PATCH v7 07/10] x86, mpx: decode MPX instruction to get bound
 violation information
Date: Mon, 21 Jul 2014 06:11:19 +0000
Message-ID: <9E0BE1322F2F2246BD820DA9FC397ADE016FC1D7@shsmsx102.ccr.corp.intel.com>
References: <1405921124-4230-1-git-send-email-qiaowei.ren@intel.com>
	<1405921124-4230-8-git-send-email-qiaowei.ren@intel.com>
 <87ppgz2qio.fsf@tassilo.jf.intel.com>
In-Reply-To: <87ppgz2qio.fsf@tassilo.jf.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>



On 2014-07-21, Andi Kleen wrote:
> Qiaowei Ren <qiaowei.ren@intel.com> writes:
>> +	 */
>> +#ifdef CONFIG_X86_64
>> +	insn->x86_64 =3D 1;
>> +	insn->addr_bytes =3D 8;
>> +#else
>> +	insn->x86_64 =3D 0;
>> +	insn->addr_bytes =3D 4;
>> +#endif
>=20
> How would that handle compat mode on a 64bit kernel?
> Should likely look at the code segment instead of ifdef.
>> +	/* Note: the upper 32 bits are ignored in 32-bit mode. */
>=20
> Again correct for compat mode? I believe the upper bits are undefined.
>=20
Compat mode will be supported on next patch in future, as 0/ patch mentione=
d. ^-^

Thanks,
Qiaowei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
