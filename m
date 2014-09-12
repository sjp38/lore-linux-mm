Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 47A356B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 23:02:57 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lf10so223466pab.36
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 20:02:56 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id oh8si5018017pbc.156.2014.09.11.20.02.55
        for <linux-mm@kvack.org>;
        Thu, 11 Sep 2014 20:02:56 -0700 (PDT)
From: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Subject: RE: [PATCH v8 09/10] x86, mpx: cleanup unused bound tables
Date: Fri, 12 Sep 2014 03:02:38 +0000
Message-ID: <9E0BE1322F2F2246BD820DA9FC397ADE017A4015@shsmsx102.ccr.corp.intel.com>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
 <1410425210-24789-10-git-send-email-qiaowei.ren@intel.com>
 <5411B8C3.7080205@intel.com>
In-Reply-To: <5411B8C3.7080205@intel.com>
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
>> + * This function will be called by do_munmap(), and the VMAs
>> + covering
>> + * the virtual address region start...end have already been split
>> + if
>> + * necessary and remvoed from the VMA list.
>=20
> "remvoed" -> "removed"
>=20
>> +void mpx_unmap(struct mm_struct *mm,
>> +		unsigned long start, unsigned long end) {
>> +	int ret;
>> +
>> +	ret =3D mpx_try_unmap(mm, start, end);
>> +	if (ret =3D=3D -EINVAL)
>> +		force_sig(SIGSEGV, current);
>> +}
>=20
> In the case of a fault during an unmap, this just ignores the
> situation and returns silently.  Where is the code to retry the
> freeing operation outside of mmap_sem?

Dave, you mean delayed_work code? According to our discussion, it will be d=
eferred to another mainline post.

Thanks,
Qiaowei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
