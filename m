Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 104AF6B0003
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 23:47:30 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id h7-v6so689482itj.7
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 20:47:30 -0700 (PDT)
Received: from mtlfep01.bell.net (belmont79srvr.owm.bell.net. [184.150.200.79])
        by mx.google.com with ESMTPS id w3-v6si146226iop.105.2018.07.25.20.47.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jul 2018 20:47:28 -0700 (PDT)
Received: from bell.net mtlfep01 184.150.200.30 by mtlfep01.bell.net
          with ESMTP
          id <20180726034728.DDOD10498.mtlfep01.bell.net@mtlspm02.bell.net>
          for <linux-mm@kvack.org>; Wed, 25 Jul 2018 23:47:28 -0400
Message-ID: <0432580c68060ed979433a04416cc19307fc5511.camel@sympatico.ca>
Subject: Re: [PATCH 0/3] PTI for x86-32 Fixes and Updates
From: "David H. Gutteridge" <dhgutteridge@sympatico.ca>
Date: Wed, 25 Jul 2018 23:47:21 -0400
In-Reply-To: <20180723072951.qesrz5pdnngtk455@suse.de>
References: <1532103744-31902-1-git-send-email-joro@8bytes.org>
	 <14206a19d597881b2490eb3fea47ee97be17ca93.camel@sympatico.ca>
	 <20180723072951.qesrz5pdnngtk455@suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <jroedel@suse.de>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>

On Mon, 2018-07-23 at 09:29 +0200, Joerg Roedel wrote:
> Hey David,
> 
> On Sun, Jul 22, 2018 at 11:49:00PM -0400, David H. Gutteridge wrote:
> > Unfortunately, I can trigger a bug in KVM+QEMU with the Bochs VGA
> > driver. (This is the same VM definition I shared with you in a PM
> > back on Feb. 20th, except note that 4.18 kernels won't successfully
> > boot with QEMU's IDE device, so I'm using SATA instead. That's a
> > regression totally unrelated to your change sets, or to the general
> > booting issue with 4.18 RC5, since it occurs in vanilla RC4 as
> > well.)
> 
> Yes, this needs the fixes in the tip/x86/mm branch as well. Can you
> that branch in and test again, please?

Sorry, I didn't realize I needed those changes, too. I've re-tested
with those applied and haven't encountered any issues. I'm now
re-testing again with your newer patch set from the 25th. No issues
so far with those, either; I'll confirm in that email thread after
the laptop has seen some more use.

Dave
