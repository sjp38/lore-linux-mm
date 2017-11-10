Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D4FBB6B02DA
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 19:57:47 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 192so879786pgd.18
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 16:57:47 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id z72si8213794pff.170.2017.11.09.16.57.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 16:57:46 -0800 (PST)
Subject: Re: [PATCH 24/30] x86, kaiser: disable native VSYSCALL
References: <20171108194646.907A1942@viggo.jf.intel.com>
 <20171108194731.AB5BDA01@viggo.jf.intel.com>
 <CALCETrUs-6yWK9uYLFmVNhYz9e1NAUbT6BPJKHge8Zkwghsesg@mail.gmail.com>
 <6871f284-b7e9-f843-608f-5345f9d03396@linux.intel.com>
 <CALCETrVFDtj5m2eA_fq9n_s4+E2u6GDA-xEfNYPkJceicT4taQ@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <27b55108-1e72-cb3d-d5d8-ffe0238245aa@linux.intel.com>
Date: Thu, 9 Nov 2017 16:57:45 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrVFDtj5m2eA_fq9n_s4+E2u6GDA-xEfNYPkJceicT4taQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On 11/09/2017 04:53 PM, Andy Lutomirski wrote:
>> The KAISER code attempts to "poison" the user portion of the kernel page
>> tables.  It detects the entries pages that it wants that it wants to
>> poison in two ways:
>>  * Looking for addresses >= PAGE_OFFSET
>>  * Looking for entries without _PAGE_USER set
> What do you mean "poison"?

I meant the _PAGE_NX magic that we do in here:

https://git.kernel.org/pub/scm/linux/kernel/git/daveh/x86-kaiser.git/commit/?h=kaiser-414rc7-20171108&id=c4f7d0819170761f092fcf2327b85b082368e73a

to ensure that userspace is unable to run on the kernel PGD.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
