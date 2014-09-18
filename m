Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 77D8B6B0055
	for <linux-mm@kvack.org>; Wed, 17 Sep 2014 22:38:20 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so410840pab.18
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 19:38:20 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id l1si37571712pdb.38.2014.09.17.19.38.19
        for <linux-mm@kvack.org>;
        Wed, 17 Sep 2014 19:38:19 -0700 (PDT)
From: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Subject: RE: [PATCH v8 08/10] x86, mpx: add prctl commands PR_MPX_REGISTER,
 PR_MPX_UNREGISTER
Date: Thu, 18 Sep 2014 02:37:50 +0000
Message-ID: <9E0BE1322F2F2246BD820DA9FC397ADE017B3436@shsmsx102.ccr.corp.intel.com>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
 <1410425210-24789-9-git-send-email-qiaowei.ren@intel.com>
 <20140916075007.GA22076@chicago.guarana.org>
 <9E0BE1322F2F2246BD820DA9FC397ADE017B32C6@shsmsx102.ccr.corp.intel.com>
 <20140918032334.GA26560@chicago.guarana.org>
In-Reply-To: <20140918032334.GA26560@chicago.guarana.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Easton <kevin@guarana.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>



On 2014-09-18, Kevin Easton wrote:
> On Thu, Sep 18, 2014 at 12:40:29AM +0000, Ren, Qiaowei wrote:
>>> Would it be prudent to use an error code other than EINVAL for the
>>> "hardware doesn't support it" case?
>>>=20
>> Seems like no specific error code for this case.
>=20
> ENXIO would probably be OK.  It's not too important as long as it's
> documented.
>=20
Yes. Looks like that ENXIO will be better.

Thanks,
Qiaowei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
