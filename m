Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 750566B061F
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 12:37:50 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id n68so39225525qkn.8
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 09:37:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x2si1100153qta.285.2018.11.08.09.37.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 09:37:49 -0800 (PST)
From: Florian Weimer <fweimer@redhat.com>
Subject: Re: pkeys: Reserve PKEY_DISABLE_READ
References: <877ehnbwqy.fsf@oldenburg.str.redhat.com>
	<2d62c9e2-375b-2791-32ce-fdaa7e7664fd@intel.com>
	<87bm6zaa04.fsf@oldenburg.str.redhat.com>
	<6f9c65fb-ea7e-8217-a4cc-f93e766ed9bb@intel.com>
Date: Thu, 08 Nov 2018 18:37:41 +0100
In-Reply-To: <6f9c65fb-ea7e-8217-a4cc-f93e766ed9bb@intel.com> (Dave Hansen's
	message of "Thu, 8 Nov 2018 09:14:54 -0800")
Message-ID: <87k1ln8o7u.fsf@oldenburg.str.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-api@vger.kernel.org, linux-mm@kvack.org, linuxram@us.ibm.com

* Dave Hansen:

> On 11/8/18 7:01 AM, Florian Weimer wrote:
>> Ideally, PKEY_DISABLE_READ | PKEY_DISABLE_WRITE and PKEY_DISABLE_READ |
>> PKEY_DISABLE_ACCESS would be treated as PKEY_DISABLE_ACCESS both, and a
>> line PKEY_DISABLE_READ would result in an EINVAL failure.
>
> Sounds reasonable to me.
>
> I don't see any urgency to do this right now.  It could easily go in
> alongside the ppc patches when those get merged.

POWER support has already been merged, so we need to do something here
now, before I can complete the userspace side.

> The only thing I'd suggest is that we make it something slightly
> higher than 0x4.  It'll make the code easier to deal with in the
> kernel if we have the ABI and the hardware mirror each other, and if
> we pick 0x4 in the ABI for PKEY_DISABLE_READ, it might get messy if
> the harware choose 0x4 for PKEY_DISABLE_EXECUTE or something.
> 
> So, let's make it 0x80 or something on x86 at least.

I don't have a problem with that if that's what it takes.

> Also, I'll be happy to review and ack the patch to do this, but I'd
> expect the ppc guys (hi Ram!) to actually put it together.

Ram, do you want to write a patch?

I'll promise I finish the glibc support for this. 8-)

Thanks,
Florian
