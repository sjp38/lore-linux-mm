Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id B1DBA6B1CF5
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 17:23:02 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id y1so20943925wrd.7
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 14:23:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d70-v6sor19814548wme.3.2018.11.19.14.23.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 14:23:01 -0800 (PST)
MIME-Version: 1.0
References: <20181119214934.6174-1-yu-cheng.yu@intel.com> <20181119214934.6174-11-yu-cheng.yu@intel.com>
In-Reply-To: <20181119214934.6174-11-yu-cheng.yu@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 19 Nov 2018 14:22:50 -0800
Message-ID: <CALCETrWP20o62m_5mp_yCBFNMQ4YYV-kPKiytHObhvJs_bjFVQ@mail.gmail.com>
Subject: Re: [RFC PATCH v6 10/11] x86/vsyscall/64: Add ENDBR64 to vsyscall
 entry points
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>

On Mon, Nov 19, 2018 at 1:55 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> From: "H.J. Lu" <hjl.tools@gmail.com>
>
> Add ENDBR64 to vsyscall entry points.
>
> Signed-off-by: H.J. Lu <hjl.tools@gmail.com>

Acked-by: Andy Lutomirski <luto@kernel.org>

although the scenarios where this matters will be extremely rare,
given that this code is mapped NX :)  Tools like 'pin' may care.

--Andy
