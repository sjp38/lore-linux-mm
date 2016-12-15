Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 508256B0267
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 15:52:59 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 17so91299857pfy.2
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 12:52:59 -0800 (PST)
Received: from mail.zytor.com (torg.zytor.com. [2001:1868:205::12])
        by mx.google.com with ESMTPS id z102si4072265plh.253.2016.12.15.12.52.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 12:52:58 -0800 (PST)
In-Reply-To: <20161215192017.GP8388@tassilo.jf.intel.com>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com> <20161208162150.148763-17-kirill.shutemov@linux.intel.com> <20161208200505.c6xiy56oufg6d24m@pd.tnic> <CA+55aFzgp+6c6RhgYvEjor=_+ewMeYL4XY4BqER5HMUknXBDCA@mail.gmail.com> <20161208202013.uutsny6avn5gimwq@pd.tnic> <b393a48a-6e8b-6427-373c-2825641fea99@zytor.com> <BD4BD1C9-F6FD-4905-9B09-059284FD2713@alien8.de> <20161215143944.ruxr6r3b2atg4tnf@pd.tnic> <E77F6B05-4F69-4C02-90B4-A8A6D0D392DE@zytor.com> <20161215190902.tdle4uj27xkc3x4i@pd.tnic> <20161215192017.GP8388@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain;
 charset=UTF-8
Subject: Re: [RFC, PATCHv1 15/28] x86: detect 5-level paging support
From: hpa@zytor.com
Date: Thu, 15 Dec 2016 12:52:24 -0800
Message-ID: <43EC6ED8-445E-436C-AC05-A2C7CB3AD9E7@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>, Borislav Petkov <bp@alien8.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On December 15, 2016 11:20:17 AM PST, Andi Kleen <ak@linux.intel.com> wrote:
>
>The code is not calling CPUID in any performance critical path, only
>at initialization. So any discussion about saving a few instructions
>is a complete waste of time.
>
>-Andi

Sort of.  The BIOS boot code is very space-constrained for certain legacy bootloaders to continue to work.  The BIOS boot code proper does not need PIC.

However, the existing .ifnc solution already takes care of it, so it doesn't matter.
-- 
Sent from my Android device with K-9 Mail. Please excuse my brevity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
