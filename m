Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 968AD6B000D
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 14:34:22 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id p125-v6so1140887itg.1
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 11:34:22 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id v3-v6si679821itd.113.2018.10.18.11.34.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 18 Oct 2018 11:34:21 -0700 (PDT)
Subject: Re: [PATCH v5 03/27] x86/fpu/xstate: Introduce XSAVES system states
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
 <20181011151523.27101-4-yu-cheng.yu@intel.com>
 <20181017104137.GE22535@zn.tnic>
 <32da559b-7958-60db-e328-f0eb316e668e@infradead.org>
 <20181017225829.GA32023@zn.tnic>
 <fde4c237-6210-f4e4-5362-c2e24a9916a2@infradead.org>
 <20181018092603.GB20831@zn.tnic>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <17222925-1c4c-0acd-c92c-637228326b66@infradead.org>
Date: Thu, 18 Oct 2018 11:33:44 -0700
MIME-Version: 1.0
In-Reply-To: <20181018092603.GB20831@zn.tnic>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 10/18/18 2:26 AM, Borislav Petkov wrote:
> On Wed, Oct 17, 2018 at 04:17:01PM -0700, Randy Dunlap wrote:
>> I asked what I really wanted to know.
> 
> Then the answer is a bit better readability, I'd guess.
> 

Thanks for the reply.

-- 
~Randy
