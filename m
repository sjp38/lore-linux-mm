Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id EE5346B0005
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 10:46:18 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g13so2806824wrh.23
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 07:46:18 -0700 (PDT)
Received: from smtp-out4.electric.net (smtp-out4.electric.net. [192.162.216.182])
        by mx.google.com with ESMTPS id q58si1540093edd.192.2018.03.29.07.46.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Mar 2018 07:46:17 -0700 (PDT)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 000/109] remove in-kernel calls to syscalls
Date: Thu, 29 Mar 2018 14:46:44 +0000
Message-ID: <07438b1e94ff42a184adb7134a680069@AcuMS.aculab.com>
References: <20180329112426.23043-1-linux@dominikbrodowski.net>
 <20180329142027.GA24860@bombadil.infradead.org>
 <20180329144209.GA25559@isilmar-4.linta.de>
In-Reply-To: <20180329144209.GA25559@isilmar-4.linta.de>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Dominik Brodowski' <linux@dominikbrodowski.net>, Matthew Wilcox <willy@infradead.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "arnd@arndb.de" <arnd@arndb.de>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "hmclauchlan@fb.com" <hmclauchlan@fb.com>, "tautschn@amazon.co.uk" <tautschn@amazon.co.uk>, Amir Goldstein <amir73il@gmail.com>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Darren
 Hart <dvhart@infradead.org>, "David S . Miller" <davem@davemloft.net>, "Eric
 W . Biederman" <ebiederm@xmission.com>, "H . Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Jaswinder Singh <jaswinder@infradead.org>, Jeff Dike <jdike@addtoit.com>, Jiri Slaby <jslaby@suse.com>, "kexec@lists.infradead.org" <kexec@lists.infradead.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "Luis R . Rodriguez" <mcgrof@kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, "user-mode-linux-devel@lists.sourceforge.net" <user-mode-linux-devel@lists.sourceforge.net>, "x86@kernel.org" <x86@kernel.org>

From: Dominik Brodowski
> Sent: 29 March 2018 15:42
> On Thu, Mar 29, 2018 at 07:20:27AM -0700, Matthew Wilcox wrote:
> > On Thu, Mar 29, 2018 at 01:22:37PM +0200, Dominik Brodowski wrote:
> > > At least on 64-bit x86, it will likely be a hard requirement from v4.=
17
> > > onwards to not call system call functions in the kernel: It is better=
 to
> > > use use a different calling convention for system calls there, where
> > > struct pt_regs is decoded on-the-fly in a syscall wrapper which then =
hands
> > > processing over to the actual syscall function. This means that only =
those
> > > parameters which are actually needed for a specific syscall are passe=
d on
> > > during syscall entry, instead of filling in six CPU registers with ra=
ndom
> > > user space content all the time (which may cause serious trouble down=
 the
> > > call chain).[*]
> >
> > How do we stop new ones from springing up?  Some kind of linker trick
> > like was used to, er, "dissuade" people from using gets()?
>=20
> Once the patches which modify the syscall calling convention are merged,
> it won't compile on 64-bit x86, but bark loudly. That should frighten any=
one.
> Meow.

Should be pretty easy to ensure the prototypes aren't in any normal header.
Renaming the global symbols (to not match the function name) will make it
much harder to call them as well.

	David
