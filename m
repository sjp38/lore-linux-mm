Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E49916B0003
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 16:49:11 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id r67-v6so9714495pfd.21
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 13:49:11 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 6-v6si27136127pgt.320.2018.10.11.13.49.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 13:49:10 -0700 (PDT)
Subject: Re: [PATCH v5 07/27] mm/mmap: Create a guard area between VMAs
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
 <20181011151523.27101-8-yu-cheng.yu@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <20167c74-9b98-6fa1-972e-bcd2c9c4a1c8@linux.intel.com>
Date: Thu, 11 Oct 2018 13:49:09 -0700
MIME-Version: 1.0
In-Reply-To: <20181011151523.27101-8-yu-cheng.yu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 10/11/2018 08:15 AM, Yu-cheng Yu wrote:
> Create a guard area between VMAs to detect memory corruption.

This is a pretty major change that has a bunch of end-user implications.
 It's not dependent on any debugging options and can't be turned on/off
by individual apps, at runtime, or even at boot.

Its connection to this series is also tenuous and not spelled out in the
exceptionally terse changelog.
