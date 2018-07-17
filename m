Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9F72F6B0006
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 22:07:52 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id g125-v6so14967188ita.0
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 19:07:52 -0700 (PDT)
Received: from torfep02.bell.net (simcoe208srvr.owm.bell.net. [184.150.200.208])
        by mx.google.com with ESMTPS id k4-v6si21006418ioa.172.2018.07.16.19.07.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Jul 2018 19:07:51 -0700 (PDT)
Received: from bell.net torfep02 184.150.200.158 by torfep02.bell.net
          with ESMTP
          id <20180717020750.ZUCS32387.torfep02.bell.net@torspm01.bell.net>
          for <linux-mm@kvack.org>; Mon, 16 Jul 2018 22:07:50 -0400
Message-ID: <18439b1a3755a6bfd8f96b1866c328ada1db0aa8.camel@sympatico.ca>
Subject: Re: [PATCH 00/39 v7] PTI support for x86-32
From: "David H. Gutteridge" <dhgutteridge@sympatico.ca>
Date: Mon, 16 Jul 2018 22:07:44 -0400
In-Reply-To: <1531308586-29340-1-git-send-email-joro@8bytes.org>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de

On Wed, 2018-07-11 at 13:29 +0200, Joerg Roedel wrote:
> Hi,
> 
> here is version 7 of my patches to enable PTI on x86-32.
> Changes to the previous version are:
> 
> 	* Rebased to v4.18-rc4
> 
> 	* Introduced pti_finalize() which is called after
> 	  mark_readonly() and used to update the kernel
> 	  mappings in the user page-table after RO/NX
> 	  protections are in place.
> 
> The patches need the vmalloc/ioremap fixes in tip/x86/mm to
> work correctly, because this enablement makes the issues
> fixed there more likely to happen.

Hi Joerg & *,

I redid my testing on bare metal and in a VM (as with my previous
testing
efforts: https://lkml.org/lkml/2018/2/19/844, same setups
and coverage,
plus CONFIG_X86_DEBUG_ENTRY_CR3 enabled too) with the
pti-x32-v7 branch,
and I didn't encounter any issues. The two DRM
drivers that were
triggering bugs in some of the prior iterations
are both behaving
properly for me.

Regards,

Dave
