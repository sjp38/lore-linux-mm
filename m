Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 293DE6B070E
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 12:20:52 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id b39-v6so1793110plb.3
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 09:20:52 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id u131-v6si7786730pgc.465.2018.11.09.09.20.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 09:20:51 -0800 (PST)
Subject: Re: [PATCH v5 04/27] x86/fpu/xstate: Add XSAVES system states for
 shadow stack
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
 <20181011151523.27101-5-yu-cheng.yu@intel.com>
 <CALCETrVAe8R=crVHoD5QmbN-gAW+V-Rwkwe4kQP7V7zQm9TM=Q@mail.gmail.com>
 <4295b8f786c10c469870a6d9725749ce75dcdaa2.camel@intel.com>
 <CALCETrUKzXYzRrWRdi8Z7AdAF0uZW5Gs7J4s=55dszoyzc29rw@mail.gmail.com>
 <043a17ef-dc9f-56d2-5fba-1a58b7b0fd4d@intel.com>
 <20181108220054.GP3074@bombadil.infradead.org>
 <ead230ab-a904-50d6-c4cf-46d5804f6151@intel.com>
 <20181109003225.GQ3074@bombadil.infradead.org>
 <6cd2ae51-2d2a-9c68-df7c-45b49e0a813f@intel.com>
 <20181109171740.GT3074@bombadil.infradead.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <ded6f43a-11d1-89bf-e00c-66c281786cff@intel.com>
Date: Fri, 9 Nov 2018 09:20:50 -0800
MIME-Version: 1.0
In-Reply-To: <20181109171740.GT3074@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Yu-cheng Yu <yu-cheng.yu@intel.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>

On 11/9/18 9:17 AM, Matthew Wilcox wrote:
>> But, later versions of the hardware have instructions that don't have
>> static offsets for the state components (when the XSAVES/XSAVEC
>> instructions are used).  So, for those, the structure embedding isn't
>> used at *all* since some state might not be present.
> But *when present*, this structure is always aligned on an 8-byte
> boundary, right?

There's no guarantee of that.

There is an "aligned" attribute for each XSAVE state component, but I do
not believe it is set for anything yet.
