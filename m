Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 500046B026A
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 12:51:26 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s7-v6so6708561pgp.3
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 09:51:26 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id n9-v6si26871225pgt.267.2018.10.11.09.51.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 09:51:25 -0700 (PDT)
Message-ID: <c3d193c68e017230dea1398f2eac4d8a8615f75e.camel@intel.com>
Subject: Re: [PATCH v5 01/27] x86/cpufeatures: Add CPUIDs for Control Flow
 Enforcement Technology (CET)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 11 Oct 2018 09:45:21 -0700
In-Reply-To: <20181011164329.GF25435@zn.tnic>
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
	 <20181011151523.27101-2-yu-cheng.yu@intel.com>
	 <20181011164329.GF25435@zn.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Thu, 2018-10-11 at 18:43 +0200, Borislav Petkov wrote:
> On Thu, Oct 11, 2018 at 08:14:57AM -0700, Yu-cheng Yu wrote:
> > Add CPUIDs for Control Flow Enforcement Technology (CET).
> 
> This is not "CPUIDs" but feature flags. Fix the subject too pls.

I will fix it.

Thanks,
Yu-cheng
