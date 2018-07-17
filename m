Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 755DF6B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 02:16:39 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d30-v6so115142edd.0
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 23:16:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w27-v6si311764eda.272.2018.07.16.23.16.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 23:16:38 -0700 (PDT)
Date: Tue, 17 Jul 2018 08:16:34 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 00/39 v7] PTI support for x86-32
Message-ID: <20180717061634.mhmidg6u5idp66kz@suse.de>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
 <18439b1a3755a6bfd8f96b1866c328ada1db0aa8.camel@sympatico.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <18439b1a3755a6bfd8f96b1866c328ada1db0aa8.camel@sympatico.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David H. Gutteridge" <dhgutteridge@sympatico.ca>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>

Hi Dave,

On Mon, Jul 16, 2018 at 10:07:44PM -0400, David H. Gutteridge wrote:
> I redid my testing on bare metal and in a VM (as with my previous
> testing
> efforts: https://lkml.org/lkml/2018/2/19/844, same setups
> and coverage,
> plus CONFIG_X86_DEBUG_ENTRY_CR3 enabled too) with the
> pti-x32-v7 branch,
> and I didn't encounter any issues. The two DRM
> drivers that were
> triggering bugs in some of the prior iterations
> are both behaving
> properly for me.

That are great news, thanks for testing, David!


Regards,

	Joerg
