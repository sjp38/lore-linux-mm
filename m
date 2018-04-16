Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 87DE56B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 13:59:30 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n78so2518763pfj.4
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 10:59:30 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [198.137.202.136])
        by mx.google.com with ESMTPS id k2si4021121pgo.509.2018.04.16.10.59.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 16 Apr 2018 10:59:29 -0700 (PDT)
Subject: Re: [PATCH 00/35 v5] PTI support for x32
References: <1523892323-14741-1-git-send-email-joro@8bytes.org>
From: "H. Peter Anvin" <hpa@zytor.com>
Message-ID: <db40f8f6-7990-676c-e536-b876254e66c0@zytor.com>
Date: Mon, 16 Apr 2018 10:57:49 -0700
MIME-Version: 1.0
In-Reply-To: <1523892323-14741-1-git-send-email-joro@8bytes.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de

On 04/16/18 08:24, Joerg Roedel wrote:
> Hi,
> 
> here is the 5th iteration of my PTI enablement patches for
> x86-32. There are no real changes between v4 and v5 besides
> that I rebased the whole patch-set to v4.17-rc1 and resolved
> the numerous conflicts that this caused.
> 

Please don't use the term "x32" for i386/x86-32.  "x32" generally refers
to the x32 ABI for x86-64.  "x64" in Microsoft terminology for x86-64
corresponds to "x86" for x86-32.

	-hpa
