Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id C73D36B0003
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 09:11:29 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id 78so2353785qky.17
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 06:11:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k39sor811840qtc.138.2018.03.09.06.11.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Mar 2018 06:11:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <89b4bb181a0622d2c581699bb3814fc041078d04.1520600533.git.andreyknvl@google.com>
References: <cover.1520600533.git.andreyknvl@google.com> <89b4bb181a0622d2c581699bb3814fc041078d04.1520600533.git.andreyknvl@google.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 9 Mar 2018 15:11:27 +0100
Message-ID: <CAK8P3a0NZfxoxeJbrebBmZDqQhD9s12xpUwMoM-rZzH8aezuYA@mail.gmail.com>
Subject: Re: [RFC PATCH 6/6] arch: add untagged_addr definition for other arches
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Philippe Ombredanne <pombredanne@nexb.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>, Kate Stewart <kstewart@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Shakeel Butt <shakeelb@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Mark Salter <msalter@redhat.com>, Aurelien Jacquiot <jacquiot.aurelien@gmail.com>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, James Hogan <jhogan@kernel.org>, Michal Simek <monstr@monstr.eu>, Ralf Baechle <ralf@linux-mips.org>, David Howells <dhowells@redhat.com>, Ley Foon Tan <lftan@altera.com>, Jonas Bonn <jonas@southpole.se>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, "James E . J . Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Chen Liqin <liqin.linux@gmail.com>, Lennox Wu <lennox.wu@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Ingo Molnar <mingo@redhat.com>, the arch/x86 maintainers <x86@kernel.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-alpha@vger.kernel.org, "open list:SYNOPSYS ARC ARCHITECTURE" <linux-snps-arc@lists.infradead.org>, adi-buildroot-devel@lists.sourceforge.net, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, "open list:METAG ARCHITECTURE" <linux-metag@vger.kernel.org>, "open list:RALINK MIPS ARCHITECTURE" <linux-mips@linux-mips.org>, linux-am33-list@redhat.com, "moderated list:NIOS2 ARCHITECTURE" <nios2-dev@lists.rocketboards.org>, openrisc@lists.librecores.org, Parisc List <linux-parisc@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-riscv@lists.infradead.org, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, linux-xtensa@linux-xtensa.org, linux-arch <linux-arch@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>

On Fri, Mar 9, 2018 at 3:02 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> To allow arm64 syscalls accept tagged pointers from userspace, we must
> untag them when they are passed to the kernel. Since untagging is done in
> generic parts of the kernel (like the mm subsystem), the untagged_addr
> macro should be defined for all architectures.
>
> Define it as a noop for all other architectures besides arm64.
>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  arch/alpha/include/asm/uaccess.h      | 2 ++
>  arch/arc/include/asm/uaccess.h        | 1 +
>  arch/arm/include/asm/uaccess.h        | 2 ++
>  arch/blackfin/include/asm/uaccess.h   | 2 ++
>  arch/c6x/include/asm/uaccess.h        | 2 ++
>  arch/cris/include/asm/uaccess.h       | 2 ++
>  arch/frv/include/asm/uaccess.h        | 2 ++
>  arch/ia64/include/asm/uaccess.h       | 2 ++
>  arch/m32r/include/asm/uaccess.h       | 2 ++
>  arch/m68k/include/asm/uaccess.h       | 2 ++
>  arch/metag/include/asm/uaccess.h      | 2 ++
>  arch/microblaze/include/asm/uaccess.h | 2 ++
>  arch/mips/include/asm/uaccess.h       | 2 ++
>  arch/mn10300/include/asm/uaccess.h    | 2 ++
>  arch/nios2/include/asm/uaccess.h      | 2 ++
>  arch/openrisc/include/asm/uaccess.h   | 2 ++
>  arch/parisc/include/asm/uaccess.h     | 2 ++
>  arch/powerpc/include/asm/uaccess.h    | 2 ++
>  arch/riscv/include/asm/uaccess.h      | 2 ++
>  arch/score/include/asm/uaccess.h      | 2 ++
>  arch/sh/include/asm/uaccess.h         | 2 ++
>  arch/sparc/include/asm/uaccess.h      | 2 ++
>  arch/tile/include/asm/uaccess.h       | 2 ++
>  arch/x86/include/asm/uaccess.h        | 2 ++
>  arch/xtensa/include/asm/uaccess.h     | 2 ++
>  include/asm-generic/uaccess.h         | 2 ++
>  26 files changed, 51 insertions(+)

I have patches to remove the blackfin, cris, frv, m32r, metag, mn10300,
score, tile and unicore32 architectures from the kernel, these should be
part of linux-next in the next few days. It's not a big issue, but if you keep
patching them, this will cause a merge conflict.

It might be easier to drop them from your patch as well.

    Arnd
