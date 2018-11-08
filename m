Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id A77876B0613
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 10:01:55 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id f22so37580689qkm.11
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 07:01:55 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l18si121648qvl.106.2018.11.08.07.01.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 07:01:54 -0800 (PST)
From: Florian Weimer <fweimer@redhat.com>
Subject: Re: pkeys: Reserve PKEY_DISABLE_READ
References: <877ehnbwqy.fsf@oldenburg.str.redhat.com>
	<2d62c9e2-375b-2791-32ce-fdaa7e7664fd@intel.com>
Date: Thu, 08 Nov 2018 16:01:47 +0100
In-Reply-To: <2d62c9e2-375b-2791-32ce-fdaa7e7664fd@intel.com> (Dave Hansen's
	message of "Thu, 8 Nov 2018 06:57:51 -0800")
Message-ID: <87bm6zaa04.fsf@oldenburg.str.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-api@vger.kernel.org, linux-mm@kvack.org, linuxram@us.ibm.com

* Dave Hansen:

> On 11/8/18 4:05 AM, Florian Weimer wrote:
>> Would it be possible to reserve a bit for PKEY_DISABLE_READ?
>> 
>> I think the POWER implementation can disable read access at the hardware
>> level, but not write access, and that cannot be expressed with the
>> current PKEY_DISABLE_ACCESS and PKEY_DISABLE_WRITE bits.
>
> Do you just mean in the syscall interfaces?  What would we need to do on
> x86 if we see the bit?  Would we just say it's invalid on x86, or would
> we make sure that PKEY_DISABLE_ACCESS==PKEY_DISABLE_READ?

Ideally, PKEY_DISABLE_READ | PKEY_DISABLE_WRITE and PKEY_DISABLE_READ |
PKEY_DISABLE_ACCESS would be treated as PKEY_DISABLE_ACCESS both, and a
line PKEY_DISABLE_READ would result in an EINVAL failure.

Thanks,
Florian
