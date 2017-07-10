Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB0266B04E2
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 17:24:08 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x23so27225907wrb.6
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 14:24:08 -0700 (PDT)
Received: from mail-wr0-x232.google.com (mail-wr0-x232.google.com. [2a00:1450:400c:c0c::232])
        by mx.google.com with ESMTPS id 77si7730934wmi.90.2017.07.10.14.24.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 14:24:07 -0700 (PDT)
Received: by mail-wr0-x232.google.com with SMTP id c11so156187545wrc.3
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 14:24:06 -0700 (PDT)
Date: Tue, 11 Jul 2017 00:24:04 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: KASAN vs. boot-time switching between 4- and 5-level paging
Message-ID: <20170710212403.7ycczkhhki3vrgac@node.shutemov.name>
References: <CACT4Y+bSTOeJtDDZVmkff=qqJFesA_b6uTG__EAn4AvDLw0jzQ@mail.gmail.com>
 <c4f11000-6138-c6ab-d075-2c4bd6a14943@virtuozzo.com>
 <75acbed7-6a08-692f-61b5-2b44f66ec0d8@virtuozzo.com>
 <bc95be68-8c68-2a45-c530-acbc6c90a231@virtuozzo.com>
 <20170710123346.7y3jnftqgpingim3@node.shutemov.name>
 <CACT4Y+aRbC7_wvDv8ahH_JwY6P6SFoLg-kdwWHJx5j1stX_P_w@mail.gmail.com>
 <20170710141713.7aox3edx6o7lrrie@node.shutemov.name>
 <03A6D7ED-300C-4431-9EB5-67C7A3EA4A2E@amacapital.net>
 <20170710184704.realchrhzpblqqlk@node.shutemov.name>
 <CALCETrVJQ_u-agPm8fFHAW1UJY=VLowdbM+gXyjFCb586r0V3g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVJQ_u-agPm8fFHAW1UJY=VLowdbM+gXyjFCb586r0V3g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>

On Mon, Jul 10, 2017 at 01:07:13PM -0700, Andy Lutomirski wrote:
> Can you give the disassembly of the backtrace lines?  Blaming the
> .endr doesn't make much sense to me.

I don't have backtrace. It's before printk() is functional. I only see
triple fault and reboot.

I had to rely on qemu tracing and gdb.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
