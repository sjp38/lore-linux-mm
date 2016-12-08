Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E94B26B0069
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 14:20:49 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id bk3so99243797wjc.4
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 11:20:49 -0800 (PST)
Received: from mail-wj0-x243.google.com (mail-wj0-x243.google.com. [2a00:1450:400c:c01::243])
        by mx.google.com with ESMTPS id m186si14551989wmm.130.2016.12.08.11.20.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 11:20:48 -0800 (PST)
Received: by mail-wj0-x243.google.com with SMTP id j10so28496272wjb.3
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 11:20:48 -0800 (PST)
Date: Thu, 8 Dec 2016 22:20:45 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC, PATCHv1 00/28] 5-level paging
Message-ID: <20161208192045.GA30380@node.shutemov.name>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
 <CA+55aFz+-8RmOMqyqQOWSjJ82byy7BpJ791-gj=xO2rPKG6KFA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFz+-8RmOMqyqQOWSjJ82byy7BpJ791-gj=xO2rPKG6KFA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Dec 08, 2016 at 10:16:07AM -0800, Linus Torvalds wrote:
> On Thu, Dec 8, 2016 at 8:21 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> >
> > This patchset is still very early. There are a number of things missing
> > that we have to do before asking anyone to merge it (listed below).
> > It would be great if folks can start testing applications now (in QEMU) to
> > look for breakage.
> > Any early comments on the design or the patches would be appreciated as
> > well.
> 
> Looks ok to me. Starting off with a compile-time config option seems fine.
> 
> I do think that the x86 cpuid part should (patch 15) should be the
> first patch, so that we see "la57" as a capability in /proc/cpuinfo
> whether it's being enabled or not? We should merge that part
> regardless of any mm patches, I think.

Okay, I'll split up the CPUID part into separate patch and move it
beginning for the patchset

REQUIRED_MASK portion will stay where it is.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
