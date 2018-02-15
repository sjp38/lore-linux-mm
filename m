Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BE4DE6B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 18:55:47 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id h10so833773pgf.3
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 15:55:47 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id z11si5685940pgc.464.2018.02.15.15.55.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 15:55:46 -0800 (PST)
Subject: Re: [PATCH 0/3] Use global pages with PTI
References: <20180215132053.6C9B48C8@viggo.jf.intel.com>
 <CA+55aFy8k_zSJ_ASyzkA9C-jLV4mZsHpv1sOxJ9qpvfS_P6eMg@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <91298252-6cef-d4ee-fa77-eb4008eb5f53@linux.intel.com>
Date: Thu, 15 Feb 2018 15:55:45 -0800
MIME-Version: 1.0
In-Reply-To: <CA+55aFy8k_zSJ_ASyzkA9C-jLV4mZsHpv1sOxJ9qpvfS_P6eMg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, the arch/x86 maintainers <x86@kernel.org>

On 02/15/2018 09:47 AM, Linus Torvalds wrote:
> On Thu, Feb 15, 2018 at 5:20 AM, Dave Hansen
> <dave.hansen@linux.intel.com> wrote:
>> During the switch over to PTI, we seem to have lost our ability to have
>> GLOBAL mappings.
...
> Did you perhaps re-run any benchmark numbers just to verify? Because
> it's always good to back up patches that should improve performance
> with actual numbers..

Same test as last time except I'm using all 4 cores on a Skylake desktop
instead of just 1.  The test is this:

> https://github.com/antonblanchard/will-it-scale/blob/master/tests/lseek1.c

With PCIDs, lseek()s/second go up around 2% to 3% with the these patches
enabling the global bit (it's noisy).  I measured it at 3% before, so
definitely the same ballpark.  That was also before all of Andy's
trampoline stuff and the syscall fast path removal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
