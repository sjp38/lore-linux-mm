Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D02B6B0253
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 13:41:03 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id 34so447620649uac.6
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 10:41:03 -0800 (PST)
Received: from mail-ua0-x22f.google.com (mail-ua0-x22f.google.com. [2607:f8b0:400c:c08::22f])
        by mx.google.com with ESMTPS id 37si7501649uac.26.2016.12.08.10.41.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 10:41:02 -0800 (PST)
Received: by mail-ua0-x22f.google.com with SMTP id 12so456634073uas.2
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 10:41:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161208162150.148763-24-kirill.shutemov@linux.intel.com>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com> <20161208162150.148763-24-kirill.shutemov@linux.intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 8 Dec 2016 10:40:41 -0800
Message-ID: <CALCETrXXNfL1OyZBa4tHm0cGz3trHV_FiJv=gtk2QRm-HrRXRg@mail.gmail.com>
Subject: Re: [RFC, PATCHv1 22/28] x86/espfix: support 5-level paging
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Dec 8, 2016 at 8:21 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> XXX: how to test this?

tools/testing/selftests/x86/sigreturn_{32,64}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
