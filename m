Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 650C16B0293
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:46:16 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 31so6561885wru.0
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 11:46:16 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id f24si2785593edc.398.2018.01.16.11.46.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 11:46:15 -0800 (PST)
Date: Tue, 16 Jan 2018 20:46:14 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
Message-ID: <20180116194614.GF28161@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1c7da3dc-279a-fa07-247b-7596cf758a55@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1c7da3dc-279a-fa07-247b-7596cf758a55@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

On Tue, Jan 16, 2018 at 10:14:19AM -0800, Dave Hansen wrote:
> Joerg,
> 
> Very cool!.

Thanks :)

> I really appreciate you putting this together.  I don't see any real
> showstoppers or things that I think will *break* 64-bit.  I just hope
> that we can merge this _slowly_ in case it breaks 64-bit along the way.

Sure, it needs a lot more testing and most likely fixing anyway. So
there is still some way to go before this is ready for merging.


	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
