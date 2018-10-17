Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id C4C0F6B0271
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 18:59:03 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id y185-v6so2220508wmg.6
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 15:59:03 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id w73-v6si2764020wme.12.2018.10.17.15.59.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 15:59:02 -0700 (PDT)
Date: Thu, 18 Oct 2018 00:58:29 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 03/27] x86/fpu/xstate: Introduce XSAVES system states
Message-ID: <20181017225829.GA32023@zn.tnic>
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
 <20181011151523.27101-4-yu-cheng.yu@intel.com>
 <20181017104137.GE22535@zn.tnic>
 <32da559b-7958-60db-e328-f0eb316e668e@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <32da559b-7958-60db-e328-f0eb316e668e@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Wed, Oct 17, 2018 at 03:39:47PM -0700, Randy Dunlap wrote:
> Would you mind explaining this request? (requirement?)
> Other than to say that it is the preference of some maintainers,
> please say Why it is preferred.
> 
> and since the <type>s above won't typically be the same length,
> it's not for variable name alignment, right?

Searching the net a little, it shows you have asked that question
before. So what is it you really wanna know?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
