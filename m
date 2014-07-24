Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 891E26B0035
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 20:49:48 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y13so2598446pdi.39
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 17:49:48 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id os6si4137795pbb.212.2014.07.23.17.49.46
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 17:49:47 -0700 (PDT)
From: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Subject: RE: [PATCH v7 09/10] x86, mpx: cleanup unused bound tables
Date: Thu, 24 Jul 2014 00:49:43 +0000
Message-ID: <9E0BE1322F2F2246BD820DA9FC397ADE01703006@shsmsx102.ccr.corp.intel.com>
References: <1405921124-4230-1-git-send-email-qiaowei.ren@intel.com>
 <1405921124-4230-10-git-send-email-qiaowei.ren@intel.com>
 <53CFE4F9.3000701@intel.com>
In-Reply-To: <53CFE4F9.3000701@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>



On 2014-07-24, Hansen, Dave wrote:
> On 07/20/2014 10:38 PM, Qiaowei Ren wrote:
>> Since the kernel allocated those tables on-demand without userspace
>> knowledge, it is also responsible for freeing them when the
>> associated mappings go away.
>>=20
>> Here, the solution for this issue is to hook do_munmap() to check
>> whether one process is MPX enabled. If yes, those bounds tables
>> covered in the virtual address region which is being unmapped will
>> be freed
> also.
>=20
> This is the part of the code that I'm the most concerned about.
>=20
> Could you elaborate on how you've tested this to make sure it works OK?

I can check a lot of debug information when one VMA and related bounds tabl=
es are allocated and freed through adding a lot of print() like log into ke=
rnel/runtime. Do you think this is enough?

Thanks,
Qiaowei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
