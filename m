Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6C64C6B025F
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 18:30:42 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q7so3010903pgr.10
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 15:30:42 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id s64si15790461pfj.279.2017.11.22.15.30.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 15:30:41 -0800 (PST)
Subject: Re: [PATCH 09/30] x86, kaiser: only populate shadow page tables for
 userspace
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
 <20171110193113.E35BC3BF@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711202057581.2348@nanos>
 <7e458284-b334-bb70-a374-c65cc4ef9f02@linux.intel.com>
 <CALCETrXv3VxEdr1UOjWW9GTFTd_BoUCpThxOxz7a4-YC+d_i=Q@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <a5dbe14a-b4f3-dc31-4622-70c2fe81ec82@linux.intel.com>
Date: Wed, 22 Nov 2017 15:30:37 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrXv3VxEdr1UOjWW9GTFTd_BoUCpThxOxz7a4-YC+d_i=Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On 11/21/2017 07:44 PM, Andy Lutomirski wrote:
>> So, I guess we could enforce that only PGDs with _PAGE_USER set can ever
>> be cleared.  That has a nice symmetry to it because we set the shadow
>> when we see _PAGE_USER and we would then clear the shadow when we see
>> _PAGE_USER.
> Is this code path ever hit in any case other than tearing down an LDT?

Do you mean the PGD clearing?  We use it for tearing down userspace
PGDs, but that's it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
