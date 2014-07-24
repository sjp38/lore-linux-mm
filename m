Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8EFEB6B0035
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 21:27:51 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lj1so2771730pab.5
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 18:27:51 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id y7si2143178pdo.12.2014.07.23.18.27.50
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 18:27:50 -0700 (PDT)
From: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Subject: RE: [PATCH v7 09/10] x86, mpx: cleanup unused bound tables
Date: Thu, 24 Jul 2014 01:27:28 +0000
Message-ID: <9E0BE1322F2F2246BD820DA9FC397ADE01703090@shsmsx102.ccr.corp.intel.com>
References: <1405921124-4230-1-git-send-email-qiaowei.ren@intel.com>
 <1405921124-4230-10-git-send-email-qiaowei.ren@intel.com>
 <53CFE4F9.3000701@intel.com>
 <9E0BE1322F2F2246BD820DA9FC397ADE01703006@shsmsx102.ccr.corp.intel.com>
 <53D05BA9.1040108@intel.com>
In-Reply-To: <53D05BA9.1040108@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>



On 2014-07-24, Hansen, Dave wrote:
> On 07/23/2014 05:49 PM, Ren, Qiaowei wrote:
>> I can check a lot of debug information when one VMA and related
>> bounds tables are allocated and freed through adding a lot of
>> print() like log into kernel/runtime. Do you think this is enough?
>=20
> I thought the entire reason we grabbed a VM_ flag was to make it
> possible to figure out without resorting to this.

All cleanup work certainly depends on this VM_ flag. In addition, as we dis=
cussed, this new VM_ flag can mainly have runtime know how much memory is o=
ccupied by MPX.

Thanks,
Qiaowei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
