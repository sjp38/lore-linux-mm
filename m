Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0FEBF6B02AC
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 11:10:16 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id s28so14921201pfg.6
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 08:10:16 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id t10si7712824plh.272.2017.11.22.08.10.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 08:10:14 -0800 (PST)
Subject: Re: MPK: removing a pkey
References: <0f006ef4-a7b5-c0cf-5f58-d0fd1f911a54@redhat.com>
 <8741e4d6-6ac0-9c07-99f3-95d8d04940b4@suse.cz>
 <813f9736-36dd-b2e5-c850-9f2d5f94514a@redhat.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <f42fe774-bdcc-a509-bb7f-fe709fd28fcb@linux.intel.com>
Date: Wed, 22 Nov 2017 08:10:10 -0800
MIME-Version: 1.0
In-Reply-To: <813f9736-36dd-b2e5-c850-9f2d5f94514a@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-x86_64@vger.kernel.org, linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>

On 11/22/2017 04:15 AM, Florian Weimer wrote:
> On 11/22/2017 09:18 AM, Vlastimil Babka wrote:
>> And, was the pkey == -1 internal wiring supposed to be exposed to the
>> pkey_mprotect() signal, or should there have been a pre-check returning
>> EINVAL in SYSCALL_DEFINE4(pkey_mprotect), before calling
>> do_mprotect_pkey())? I assume it's too late to change it now anyway (or
>> not?), so should we also document it?
> 
> I think the -1 case to the set the default key is useful because it
> allows you to use a key value of -1 to mean a??MPK is not supporteda??, and
> still call pkey_mprotect.

The behavior to not allow 0 to be set was unintentional and is a bug.
We should fix that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
