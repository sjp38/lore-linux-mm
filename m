Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 83D1D6B7005
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 13:16:45 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id g184so5992158wmd.4
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 10:16:45 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id k6si13382493wrv.173.2018.12.04.10.16.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 10:16:44 -0800 (PST)
Date: Tue, 4 Dec 2018 19:16:41 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v6 04/26] x86/fpu/xstate: Introduce XSAVES system
 states
Message-ID: <20181204181641.GA16705@zn.tnic>
References: <20181119214809.6086-1-yu-cheng.yu@intel.com>
 <20181119214809.6086-5-yu-cheng.yu@intel.com>
 <20181204160144.GG11803@zn.tnic>
 <752c38422a6536d8df99b619214f935e4bc882ad.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <752c38422a6536d8df99b619214f935e4bc882ad.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Tue, Dec 04, 2018 at 09:08:11AM -0800, Yu-cheng Yu wrote:
> Then we will do this very often.  Why don't we create all three in the
> beginning: xfeatures_mask_all, xfeatures_mask_user, and xfeatures_mask_system?

Because the _all thing is the OR-ed product of the two and then you
don't have to update it when the _user and the _system ones change
because you'll be creating it on the fly each time.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
