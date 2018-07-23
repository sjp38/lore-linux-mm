Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id A0E776B0003
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 03:30:00 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 31-v6so9831098pld.6
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 00:30:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v17-v6si8471342pgk.135.2018.07.23.00.29.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 00:29:59 -0700 (PDT)
Date: Mon, 23 Jul 2018 09:29:51 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 0/3] PTI for x86-32 Fixes and Updates
Message-ID: <20180723072951.qesrz5pdnngtk455@suse.de>
References: <1532103744-31902-1-git-send-email-joro@8bytes.org>
 <14206a19d597881b2490eb3fea47ee97be17ca93.camel@sympatico.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <14206a19d597881b2490eb3fea47ee97be17ca93.camel@sympatico.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David H. Gutteridge" <dhgutteridge@sympatico.ca>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>

Hey David,

On Sun, Jul 22, 2018 at 11:49:00PM -0400, David H. Gutteridge wrote:
> Unfortunately, I can trigger a bug in KVM+QEMU with the Bochs VGA
> driver. (This is the same VM definition I shared with you in a PM
> back on Feb. 20th, except note that 4.18 kernels won't successfully
> boot with QEMU's IDE device, so I'm using SATA instead. That's a
> regression totally unrelated to your change sets, or to the general
> booting issue with 4.18 RC5, since it occurs in vanilla RC4 as well.)

Yes, this needs the fixes in the tip/x86/mm branch as well. Can you that
branch in and test again, please?


Thanks,

	Joerg
