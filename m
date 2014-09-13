Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id A1BFA6B0035
	for <linux-mm@kvack.org>; Sat, 13 Sep 2014 03:24:13 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id fa1so2863696pad.2
        for <linux-mm@kvack.org>; Sat, 13 Sep 2014 00:24:13 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id rt2si12231875pbc.18.2014.09.13.00.24.12
        for <linux-mm@kvack.org>;
        Sat, 13 Sep 2014 00:24:12 -0700 (PDT)
From: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Subject: RE: [PATCH v8 04/10] x86, mpx: hook #BR exception handler to
 allocate bound tables
Date: Sat, 13 Sep 2014 07:24:02 +0000
Message-ID: <9E0BE1322F2F2246BD820DA9FC397ADE017A5821@shsmsx102.ccr.corp.intel.com>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
 <1410425210-24789-5-git-send-email-qiaowei.ren@intel.com>
 <54137A79.6060602@intel.com>
In-Reply-To: <54137A79.6060602@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>



On 2014-09-13, Hansen, Dave wrote:
> On 09/11/2014 01:46 AM, Qiaowei Ren wrote:
>> +static int allocate_bt(long __user *bd_entry) {
>> +	unsigned long bt_addr, old_val =3D 0;
>> +	int ret =3D 0;
>> +
>> +	bt_addr =3D mpx_mmap(MPX_BT_SIZE_BYTES);
>> +	if (IS_ERR((void *)bt_addr))
>> +		return bt_addr;
>> +	bt_addr =3D (bt_addr & MPX_BT_ADDR_MASK) |
> MPX_BD_ENTRY_VALID_FLAG;
>=20
> Qiaowei, why do we need the "& MPX_BT_ADDR_MASK" here?

It should be not necessary, and can be removed.

Thanks,
Qiaowei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
