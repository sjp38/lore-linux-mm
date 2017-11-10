Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B2B58440D03
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 01:31:33 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id i196so8137650pgd.2
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 22:31:33 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id s16si7836312plp.187.2017.11.09.22.31.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 22:31:32 -0800 (PST)
Subject: Re: [PATCH 24/30] x86, kaiser: disable native VSYSCALL
References: <20171108194646.907A1942@viggo.jf.intel.com>
 <20171108194731.AB5BDA01@viggo.jf.intel.com>
 <CALCETrUs-6yWK9uYLFmVNhYz9e1NAUbT6BPJKHge8Zkwghsesg@mail.gmail.com>
 <6871f284-b7e9-f843-608f-5345f9d03396@linux.intel.com>
 <CALCETrVFDtj5m2eA_fq9n_s4+E2u6GDA-xEfNYPkJceicT4taQ@mail.gmail.com>
 <27b55108-1e72-cb3d-d5d8-ffe0238245aa@linux.intel.com>
 <CALCETrXy-K5fKzvjF-Dr6gVpJ+ui4c-GjrT6Oruh5ePvPudPpg@mail.gmail.com>
 <4c8c441e-d65c-fcec-7718-6997bd010971@linux.intel.com>
 <CALCETrXzmtoS-vHF3AHVZtuf0LsDsFLDUMSk0TjT0eOfGHjHkQ@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <f5483db4-018c-3474-0819-65336cacdb1d@linux.intel.com>
Date: Thu, 9 Nov 2017 22:31:30 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrXzmtoS-vHF3AHVZtuf0LsDsFLDUMSk0TjT0eOfGHjHkQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On 11/09/2017 06:25 PM, Andy Lutomirski wrote:
> Here are two proposals to address this without breaking vsyscalls.
> 
> 1. Set NX on low mappings that are _PAGE_USER.  Don't set NX on high
> mappings but, optionally, warn if you see _PAGE_USER on any address
> that isn't the vsyscall page.
> 
> 2. Ignore _PAGE_USER entirely and just mark the EFI mm as special so
> KAISER doesn't muck with it.

These are totally doable.  But, what's the big deal with breaking native
vsyscall?  We can still do the emulation so nothing breaks: it is just slow.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
