Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 548676B0037
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 22:53:19 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id md12so6617096pbc.17
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 19:53:18 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id rm10si24367710pab.197.2014.06.23.19.53.17
        for <linux-mm@kvack.org>;
        Mon, 23 Jun 2014 19:53:18 -0700 (PDT)
From: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Subject: RE: [PATCH v6 02/10] x86, mpx: add MPX specific mmap interface
Date: Tue, 24 Jun 2014 02:53:12 +0000
Message-ID: <9E0BE1322F2F2246BD820DA9FC397ADE016AF2DB@shsmsx102.ccr.corp.intel.com>
References: <1403084656-27284-1-git-send-email-qiaowei.ren@intel.com>
 <1403084656-27284-3-git-send-email-qiaowei.ren@intel.com>
 <53A884B2.5070702@mit.edu>
In-Reply-To: <53A884B2.5070702@mit.edu>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>
Cc: "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On 2014-06-24, Andy Lutomirski wrote:
>> +	/* Make bounds tables and bouds directory unlocked. */
>> +	if (vm_flags & VM_LOCKED)
>> +		vm_flags &=3D ~VM_LOCKED;
>=20
> Why?  I would expect MCL_FUTURE to lock these.
>=20
Andy, I was just a little confused about LOCKED & POPULATE earlier and I th=
ought VM_LOCKED is not necessary for MPX specific bounds tables. Now, this =
checking should be removed, and there should be mm_populate() for VM_LOCKED=
 case after mmap_region():

   if (!IS_ERR_VALUE(addr) && (vm_flags & VM_LOCKED))
       mm_populate(addr, len);

Thanks,
Qiaowei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
