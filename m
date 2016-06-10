From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: x86: bad pte in pageattr_test
Date: Fri, 10 Jun 2016 14:54:59 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1606101253090.28031@nanos>
References: <CACT4Y+YwV++Eb8n-1q94zW7_rOOX=p8_+8ERD9L07cjrBf7ysw@mail.gmail.com> <CACT4Y+ZTFGqVjokXUefFMJOrhAn+go3hPKvQRdAhgRRhab5GrQ@mail.gmail.com> <CACT4Y+b8f7=ZnvXnzP17nDwa_jvDeTTQY_Wy7wsiohRssDULhQ@mail.gmail.com> <alpine.DEB.2.11.1606092240030.28031@nanos>
 <CACT4Y+YWqcCU0z+LS5BboJOxMRYys_sbUPQTA5to5GcUUQK4LQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+YWqcCU0z+LS5BboJOxMRYys_sbUPQTA5to5GcUUQK4LQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>
List-Id: linux-mm.kvack.org

On Fri, 10 Jun 2016, Dmitry Vyukov wrote:
> Here is the second log:
> https://gist.githubusercontent.com/dvyukov/dd7970a5daaa7a30f6d37fa5592b56de/raw/f29182024538e604c95d989f7b398816c3c595dc/gistfile1.txt
> 
> I've hit only twice. The first time I tried hard to reproduce it, with
> no success. So unfortunately that's all we have.
> 
> Re logs: my setup executes up to 16 programs in parallel. So for
> normal BUGs any of the preceding 16 programs can be guilty. But since
> this check is asynchronous, it can be just any preceding program in
> the log.

Ok.
 
> I would expect that it is triggered by some rarely-executing poorly
> tested code. Maybe mmap of some device?

That's the mmap(dev) list which is common between the two log files:

vcsn
ircomm
rfkill
userio
dspn
mice
midi
sndpcmc
hidraw0
vga_arbiter
lightnvm
sr

Dunno, if that's the right direction, but exposing these a bit more might be
worth to try.

Thanks,

	tglx
