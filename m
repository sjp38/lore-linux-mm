Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 19E896B0003
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 00:33:10 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id y64-v6so15484590itd.4
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 21:33:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o73-v6sor975495ito.135.2018.04.02.21.33.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Apr 2018 21:33:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180402190454.GB29890@light.dominikbrodowski.net>
References: <20180402190454.GB29890@light.dominikbrodowski.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 2 Apr 2018 21:33:07 -0700
Message-ID: <CA+55aFyaVVKKbXPFzW1Tr7CTpiLCK+1nGdhS21wnm1j64bqWPA@mail.gmail.com>
Subject: Re: [GIT PULL] remove in-kernel calls to syscalls
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominik Brodowski <linux@dominikbrodowski.net>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, linux-arch <linux-arch@vger.kernel.org>, hmclauchlan@fb.com, tautschn@amazon.co.uk, Amir Goldstein <amir73il@gmail.com>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Darren Hart <dvhart@infradead.org>, "David S. Miller" <davem@davemloft.net>, "Eric W. Biederman" <ebiederm@xmission.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Jaswinder Singh <jaswinder@infradead.org>, Jeff Dike <jdike@addtoit.com>, Jiri Slaby <jslaby@suse.com>, Kexec Mailing List <kexec@lists.infradead.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-s390 <linux-s390@vger.kernel.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Network Development <netdev@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, uml-devel <user-mode-linux-devel@lists.sourceforge.net>, the arch/x86 maintainers <x86@kernel.org>

On Mon, Apr 2, 2018 at 12:04 PM, Dominik Brodowski
<linux@dominikbrodowski.net> wrote:
>
> This patchset removes all in-kernel calls to syscall functions in the
> kernel with the exception of arch/.

Ok, this finished off my arch updates for today, I'll probably move on
to driver pulls tomorrow.

Anyway, it's in my tree, will push out once my test build finishes.

                Linus
