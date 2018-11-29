Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id E920F6B53EE
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 13:24:55 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id g204-v6so1491856oia.21
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 10:24:55 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j23si1134512otn.21.2018.11.29.10.24.55
        for <linux-mm@kvack.org>;
        Thu, 29 Nov 2018 10:24:55 -0800 (PST)
Date: Thu, 29 Nov 2018 18:24:48 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v8 3/8] arm64: untag user addresses in access_ok and
 __uaccess_mask_ptr
Message-ID: <20181129182446.GJ22027@arrakis.emea.arm.com>
References: <cover.1541687720.git.andreyknvl@google.com>
 <b23c2374235a33328817f2586cc055c69d91a2ec.1541687720.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b23c2374235a33328817f2586cc055c69d91a2ec.1541687720.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Evgeniy Stepanov <eugenis@google.com>

On Thu, Nov 08, 2018 at 03:36:10PM +0100, Andrey Konovalov wrote:
> copy_from_user (and a few other similar functions) are used to copy data
> from user memory into the kernel memory or vice versa. Since a user can
> provided a tagged pointer to one of the syscalls that use copy_from_user,
> we need to correctly handle such pointers.
> 
> Do this by untagging user pointers in access_ok and in __uaccess_mask_ptr,
> before performing access validity checks.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
