Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id D61996B0071
	for <linux-mm@kvack.org>; Mon, 18 May 2015 13:36:10 -0400 (EDT)
Received: by pabru16 with SMTP id ru16so160704245pab.1
        for <linux-mm@kvack.org>; Mon, 18 May 2015 10:36:10 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id hq6si16925152pbc.96.2015.05.18.10.36.09
        for <linux-mm@kvack.org>;
        Mon, 18 May 2015 10:36:10 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [RFC 3/3] x86, mirror: x86 enabling - find mirrored memory
 ranges and tell memblock
Date: Mon, 18 May 2015 17:36:07 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32A86CA0@ORSMSX114.amr.corp.intel.com>
References: <cover.1423259664.git.tony.luck@intel.com>
 <7bdbb1a569d487b3a772fbb7b66b9498d6cee551.1423259664.git.tony.luck@intel.com>
 <55599E2F.4060800@huawei.com>
In-Reply-To: <55599E2F.4060800@huawei.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Xiexiuqi <xiexiuqi@huawei.com>, Linux MM <linux-mm@kvack.org>

On 2015/2/4 6:40, Tony Luck wrote:
>> Can't post this part yet because it uses things in an upcoming[*] ACPI, =
UEFI, or some
>> other four-letter-ending-in-I standard.  So just imagine a call someplac=
e early
>> in startup that reads information about mirrored address ranges and does=
:
>>=20

> Does the upcoming[*] ACPI will add a new flag in SRAT tables? just like m=
emory hotplug.
>
> #define ACPI_SRAT_MEM_HOT_PLUGGABLE (1<<1)	/* 01: Memory region is hot pl=
uggable */
> +#define ACPI_SRAT_MEM_MIRROR	    (1<<3)	/* 03: Memory region is mirrored=
 */

The choice for this was UEFI - new attribute bit in the GetMemoryMap() retu=
rn value.

UEFI 2.5 has been published with this change and I posted a newer patch 10 =
days ago:

  https://lkml.org/lkml/2015/5/8/521

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
