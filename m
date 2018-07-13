Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 41B046B0007
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 14:05:47 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id x2-v6so2643025pgr.15
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 11:05:47 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id w25-v6si23748329pga.58.2018.07.13.11.05.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 11:05:44 -0700 (PDT)
Subject: Re: [RFC PATCH v2 22/27] x86/cet/ibt: User-mode indirect branch
 tracking support
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-23-yu-cheng.yu@intel.com>
 <3a7e9ce4-03c6-cc28-017b-d00108459e94@linux.intel.com>
 <1531347019.15351.89.camel@intel.com>
 <f97ce234-52fa-e666-2250-098925cf3c39@linux.intel.com>
 <1531350028.15351.102.camel@intel.com>
 <25675609-9ea7-55fb-6e73-b4a4c49b6c35@linux.intel.com>
 <1531504609.11680.16.camel@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <aa89221e-8900-12f5-d40e-d1db78b11845@linux.intel.com>
Date: Fri, 13 Jul 2018 11:05:23 -0700
MIME-Version: 1.0
In-Reply-To: <1531504609.11680.16.camel@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 07/13/2018 10:56 AM, Yu-cheng Yu wrote:
>>> GLIBC does the bitmap setup. A It sets bits in there.
>>> I thought you wanted a smaller bitmap? A One way is forcing legacy libs
>>> to low address, or not having the bitmap at all, i.e. turn IBT off.
>> I'm concerned with two things:
>> 1. the virtual address space consumption, especially the *default* case
>> A A A which will be apps using 4-level address space amounts, but having
>> A A A 5-level-sized tables.
>> 2. the driving a truck-sized hole in the address space limits
>>
>> You can force legacy libs to low addresses, but you can't stop anyone
>> from putting code into a high address *later*, at least with the code we
>> have today.
> So we will always reserve a big space for all CET tasks?

Yes.  You either hard-restrict the address space (which we can't do
currently) or you reserve a big space.

> Currently if an application does dlopen() a legacy lib, it will have only
> partial IBT protection and no SHSTK. A Do we want to consider simply turning
> off IBT in that case?

I don't know.  I honestly don't understand the threat model enough to
give you a good answer.  Is there background on this in the docs?
