Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 991CD6B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 10:00:37 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id f6so305207pfe.16
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 07:00:37 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id j1si16331455pgc.771.2017.11.23.07.00.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 07:00:36 -0800 (PST)
Subject: Re: MPK: removing a pkey
References: <0f006ef4-a7b5-c0cf-5f58-d0fd1f911a54@redhat.com>
 <8741e4d6-6ac0-9c07-99f3-95d8d04940b4@suse.cz>
 <813f9736-36dd-b2e5-c850-9f2d5f94514a@redhat.com>
 <f42fe774-bdcc-a509-bb7f-fe709fd28fcb@linux.intel.com>
 <9ec19ff3-86f6-7cfe-1a07-1ab1c5d9882c@redhat.com>
 <d98eb4b8-6e59-513d-fdf8-3395485cb851@linux.intel.com>
 <de93997a-7802-96cf-62e2-e59416e745ca@suse.cz>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <17831167-7142-d42a-c7a0-59bdc8bbb786@linux.intel.com>
Date: Thu, 23 Nov 2017 07:00:32 -0800
MIME-Version: 1.0
In-Reply-To: <de93997a-7802-96cf-62e2-e59416e745ca@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Florian Weimer <fweimer@redhat.com>, linux-x86_64@vger.kernel.org, linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>

On 11/23/2017 12:11 AM, Vlastimil Babka wrote:
>> No, the default is clearly 0 and documented to be so.  The PROT_EXEC
>> emulation one should be inaccessible in all the APIs so does not even
>> show up as *being* a key in the API.  The fact that it's implemented
>> with pkeys should be pretty immaterial other than the fact that you
>> can't touch the high bits in PKRU.
> So, just to be sure, if we call pkey_mprotect() with 0, will it blindly
> set 0, or the result of arch_override_mprotect_pkey() (thus equivalent
> to call with -1) ? I assume the latter?

It's supposed to set 0.

-1 was, as far as I remember, an internal-to-the-kernel-only thing to
tell us that a key came from *mprotect()* instead of pkey_mprotect().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
