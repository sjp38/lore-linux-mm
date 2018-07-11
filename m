Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2FD3B6B000D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 09:47:08 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id s200-v6so35208314oie.6
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 06:47:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g3-v6sor13063888oic.254.2018.07.11.06.47.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 06:47:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <ae3e2013-9c90-af39-f9da-278bf7af6f73@redhat.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com> <20180710222639.8241-6-yu-cheng.yu@intel.com>
 <ae3e2013-9c90-af39-f9da-278bf7af6f73@redhat.com>
From: "H.J. Lu" <hjl.tools@gmail.com>
Date: Wed, 11 Jul 2018 06:47:06 -0700
Message-ID: <CAMe9rOqo3ZSMuwNZf8HbrL72OY1aQ0S0Huwqj7rsVY9_ZOfF_A@mail.gmail.com>
Subject: Re: [RFC PATCH v2 05/27] Documentation/x86: Add CET description
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Wed, Jul 11, 2018 at 2:57 AM, Florian Weimer <fweimer@redhat.com> wrote:
> On 07/11/2018 12:26 AM, Yu-cheng Yu wrote:
>
>> +To build a CET-enabled kernel, Binutils v2.30 and GCC v8.1 or later
>> +are required.  To build a CET-enabled application, GLIBC v2.29 or
>> +later is also requried.
>
>
> Have you given up on getting the required changes into glibc 2.28?
>

This is a typo.  We are still targeting for 2.28.  All pieces are there.

-- 
H.J.
