Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AC0236B0006
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 06:24:52 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b34-v6so6888685ede.5
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 03:24:52 -0700 (PDT)
Received: from albireo.enyo.de (albireo.enyo.de. [5.158.152.32])
        by mx.google.com with ESMTPS id j13-v6si995600eda.397.2018.10.12.03.24.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Oct 2018 03:24:51 -0700 (PDT)
From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: [PATCH v5 07/27] mm/mmap: Create a guard area between VMAs
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
	<20181011151523.27101-8-yu-cheng.yu@intel.com>
	<20167c74-9b98-6fa1-972e-bcd2c9c4a1c8@linux.intel.com>
Date: Fri, 12 Oct 2018 12:24:25 +0200
In-Reply-To: <20167c74-9b98-6fa1-972e-bcd2c9c4a1c8@linux.intel.com> (Dave
	Hansen's message of "Thu, 11 Oct 2018 13:49:09 -0700")
Message-ID: <87va67799i.fsf@mid.deneb.enyo.de>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

* Dave Hansen:

> On 10/11/2018 08:15 AM, Yu-cheng Yu wrote:
>> Create a guard area between VMAs to detect memory corruption.
>
> This is a pretty major change that has a bunch of end-user implications.
>  It's not dependent on any debugging options and can't be turned on/off
> by individual apps, at runtime, or even at boot.
>
> Its connection to this series is also tenuous and not spelled out in the
> exceptionally terse changelog.

I agree.  We did have application failures due to the introduction of
the stack gap, so this change is likely to cause failures when applied
to existing mappings as well.
