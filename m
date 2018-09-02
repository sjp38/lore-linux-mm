Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C62576B6138
	for <linux-mm@kvack.org>; Sun,  2 Sep 2018 04:13:55 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id a8-v6so783489pla.10
        for <linux-mm@kvack.org>; Sun, 02 Sep 2018 01:13:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q202-v6sor3898669pgq.307.2018.09.02.01.13.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 02 Sep 2018 01:13:54 -0700 (PDT)
Date: Sun, 2 Sep 2018 18:13:50 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [RFC PATCH v3 00/24] Control Flow Enforcement: Shadow Stack
Message-ID: <20180902081350.GF28695@350D>
References: <20180830143904.3168-1-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180830143904.3168-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Thu, Aug 30, 2018 at 07:38:40AM -0700, Yu-cheng Yu wrote:
> The previous version of CET patches can be found in the following
> link.
> 
>   https://lkml.org/lkml/2018/7/10/1031
> 
> Summary of changes from v2:
> 
>   Move Shadow Stack page fault handling logic to arch/x86.
>   Update can_follow_write_pte/pmd; move logic to arch/x86.
>   Fix problems in WRUSS in-line assembly.
>   Fix issues in ELF parser.
>   Split out IBT/PTRACE patches to a second set.
>   Other small fixes.
>

Quick question -- is there a simulator or some other way you've
been testing this? Just curious, if it's possible to run these
patches or just a review and internal hardware/simulator where
they are run and posted

Balbir Singh.
