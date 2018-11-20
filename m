Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B9D9B6B21B8
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 15:41:58 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id m13so3346805pls.15
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 12:41:58 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 19si41239578pgp.186.2018.11.20.12.41.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 12:41:57 -0800 (PST)
Message-ID: <16a0261fbe4b31e2f42b552d6a991a1116d398c2.camel@intel.com>
Subject: Re: [RFC PATCH v6 01/26] Documentation/x86: Add CET description
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Tue, 20 Nov 2018 12:36:38 -0800
In-Reply-To: <20181120095253.GA119911@gmail.com>
References: <20181119214809.6086-1-yu-cheng.yu@intel.com>
	 <20181119214809.6086-2-yu-cheng.yu@intel.com>
	 <20181120095253.GA119911@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Tue, 2018-11-20 at 10:52 +0100, Ingo Molnar wrote:
> * Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> 
> > +X86 Documentation
> > [...]
> > +
> > +At run time, /proc/cpuinfo shows the availability of SHSTK and IBT.
> 
> What is the rough expected performance impact of CET on average function 
> call frequency user applications and the kernel itself?

I don't have any conclusive numbers yet; but since currently only user-mode
protection is implemented, I suspect any impact would be most likely to the
application.  The kernel would spend some small amount of time on the setup of
CET.

Yu-cheng
