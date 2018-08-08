Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 747116B0003
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 11:54:40 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id t26-v6so1613989pfh.0
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 08:54:40 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id j5-v6si4710997pgt.226.2018.08.08.08.54.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Aug 2018 08:54:39 -0700 (PDT)
Subject: Re: [PATCH] x86/mm/pti: Move user W+X check into pti_finalize()
References: <1533727000-9172-1-git-send-email-joro@8bytes.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <aee38579-3a53-3370-b22b-04603b6b65ce@intel.com>
Date: Wed, 8 Aug 2018 08:54:37 -0700
MIME-Version: 1.0
In-Reply-To: <1533727000-9172-1-git-send-email-joro@8bytes.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de

On 08/08/2018 04:16 AM, Joerg Roedel wrote:
> But with CONFIG_DEBUG_WX enabled, the user page-table is
> already checked in mark_readonly() for insecure mappings.
> This causes false-positive warnings, because the user
> page-table did not get the updated mappings yet.

One bit of information missing from the changelog: Could you clarify how
there are any entries in the user page tables for the code to complain?
Before pti_init(), I would have expected the user page tables to be empty.

That causes a different problem, but it would not have resulted in
warnings, so I think I'm missing something.
