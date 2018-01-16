Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BC38F6B0277
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 13:14:21 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f5so9701282pgp.18
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 10:14:21 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id o1si2420326pld.310.2018.01.16.10.14.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 10:14:20 -0800 (PST)
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <1c7da3dc-279a-fa07-247b-7596cf758a55@intel.com>
Date: Tue, 16 Jan 2018 10:14:19 -0800
MIME-Version: 1.0
In-Reply-To: <1516120619-1159-1-git-send-email-joro@8bytes.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

Joerg,

Very cool!.

I really appreciate you putting this together.  I don't see any real
showstoppers or things that I think will *break* 64-bit.  I just hope
that we can merge this _slowly_ in case it breaks 64-bit along the way.

I didn't look at the assembly in too much detail.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
