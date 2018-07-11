Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id A92C56B0006
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 08:19:55 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id j11-v6so16452797qtp.0
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 05:19:55 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id t81-v6si2986061qka.286.2018.07.11.05.19.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 05:19:54 -0700 (PDT)
Subject: Re: [RFC PATCH v2 27/27] x86/cet: Add arch_prctl functions for CET
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-28-yu-cheng.yu@intel.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <bbd9d3d7-a456-d161-6bc6-19e555edcd01@redhat.com>
Date: Wed, 11 Jul 2018 14:19:43 +0200
MIME-Version: 1.0
In-Reply-To: <20180710222639.8241-28-yu-cheng.yu@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 07/11/2018 12:26 AM, Yu-cheng Yu wrote:
> arch_prctl(ARCH_CET_DISABLE, unsigned long features)
>      Disable SHSTK and/or IBT specified in 'features'.  Return -EPERM
>      if CET is locked out.
> 
> arch_prctl(ARCH_CET_LOCK)
>      Lock out CET feature.

Isn't it a a??lock ina?? rather than a a??lock outa???

Thanks,
Florian
