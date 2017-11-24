Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A74106B0253
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 03:39:55 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 4so21149171pge.8
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 00:39:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y84si4015701pfa.362.2017.11.24.00.39.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 00:39:54 -0800 (PST)
Subject: Re: MPK: removing a pkey
References: <0f006ef4-a7b5-c0cf-5f58-d0fd1f911a54@redhat.com>
 <8741e4d6-6ac0-9c07-99f3-95d8d04940b4@suse.cz>
 <813f9736-36dd-b2e5-c850-9f2d5f94514a@redhat.com>
 <f42fe774-bdcc-a509-bb7f-fe709fd28fcb@linux.intel.com>
 <9ec19ff3-86f6-7cfe-1a07-1ab1c5d9882c@redhat.com>
 <d98eb4b8-6e59-513d-fdf8-3395485cb851@linux.intel.com>
 <de93997a-7802-96cf-62e2-e59416e745ca@suse.cz>
 <17831167-7142-d42a-c7a0-59bdc8bbb786@linux.intel.com>
 <2d12777f-615a-8101-2156-cf861ec13aa7@suse.cz>
 <8051353f-47d3-37a4-a402-41adc8b6eb88@linux.intel.com>
 <e97e53a1-ba04-c62e-cc64-054b488d5394@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <346db028-6f45-65d5-a531-300c2251a8eb@suse.cz>
Date: Fri, 24 Nov 2017 09:38:27 +0100
MIME-Version: 1.0
In-Reply-To: <e97e53a1-ba04-c62e-cc64-054b488d5394@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-x86_64@vger.kernel.org, linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>

On 11/24/2017 09:35 AM, Florian Weimer wrote:
> On 11/24/2017 12:29 AM, Dave Hansen wrote:
>> Although weird, the thought here was that pkey_mprotect() callers are
>> new and should know about the interactions with PROT_EXEC.  They can
>> also*get*  PROT_EXEC semantics if they want.
>>
>> The only wart here is if you do:
>>
>> 	mprotect(..., PROT_EXEC); // key 10 is now the PROT_EXEC key
> 
> I thought the PROT_EXEC key is always 1?

Seems it assigns the first non-allocated one. Can even fail if there's
none left, and then there's no PROT_EXEC read protection. In practice I
expect PROT_EXEC mapping to be created by ELF loader (?) before the
program can even call pkey_alloc() itself, so it would be 1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
