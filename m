Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 481976B0038
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 09:22:34 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id o3so25420702wjo.1
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 06:22:34 -0800 (PST)
Received: from mail-wj0-x244.google.com (mail-wj0-x244.google.com. [2a00:1450:400c:c01::244])
        by mx.google.com with ESMTPS id rz16si44596553wjb.93.2016.12.12.06.22.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 06:22:32 -0800 (PST)
Received: by mail-wj0-x244.google.com with SMTP id he10so11809639wjc.2
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 06:22:31 -0800 (PST)
Date: Mon, 12 Dec 2016 17:22:29 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC, PATCHv1 22/28] x86/espfix: support 5-level paging
Message-ID: <20161212142229.GA4208@node>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
 <20161208162150.148763-24-kirill.shutemov@linux.intel.com>
 <CALCETrXXNfL1OyZBa4tHm0cGz3trHV_FiJv=gtk2QRm-HrRXRg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXXNfL1OyZBa4tHm0cGz3trHV_FiJv=gtk2QRm-HrRXRg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Dec 08, 2016 at 10:40:41AM -0800, Andy Lutomirski wrote:
> On Thu, Dec 8, 2016 at 8:21 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > XXX: how to test this?
> 
> tools/testing/selftests/x86/sigreturn_{32,64}

Hm. They fail on non-patched kernel with QEMU, but not KVM. :-/
I guess I'd need to fix QEMU first.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
