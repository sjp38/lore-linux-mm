Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id DCBEA6B0253
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 14:20:18 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id a1so255765pgf.6
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 11:20:18 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id b27si3817819pfe.274.2016.12.15.11.20.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 11:20:18 -0800 (PST)
Date: Thu, 15 Dec 2016 11:20:17 -0800
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [RFC, PATCHv1 15/28] x86: detect 5-level paging support
Message-ID: <20161215192017.GP8388@tassilo.jf.intel.com>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
 <20161208162150.148763-17-kirill.shutemov@linux.intel.com>
 <20161208200505.c6xiy56oufg6d24m@pd.tnic>
 <CA+55aFzgp+6c6RhgYvEjor=_+ewMeYL4XY4BqER5HMUknXBDCA@mail.gmail.com>
 <20161208202013.uutsny6avn5gimwq@pd.tnic>
 <b393a48a-6e8b-6427-373c-2825641fea99@zytor.com>
 <BD4BD1C9-F6FD-4905-9B09-059284FD2713@alien8.de>
 <20161215143944.ruxr6r3b2atg4tnf@pd.tnic>
 <E77F6B05-4F69-4C02-90B4-A8A6D0D392DE@zytor.com>
 <20161215190902.tdle4uj27xkc3x4i@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161215190902.tdle4uj27xkc3x4i@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: hpa@zytor.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>


The code is not calling CPUID in any performance critical path, only
at initialization. So any discussion about saving a few instructions
is a complete waste of time.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
