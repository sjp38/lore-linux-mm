Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 06C0E6B038A
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 21:03:17 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id r45so52407678qte.6
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 18:03:17 -0700 (PDT)
Subject: Re: [RFC PATCH 00/13] Introduce first class virtual address spaces
References: <20170314003935.2jwycgajo7eojmvm@arch-dev>
From: Richard Henderson <rth@twiddle.net>
Message-ID: <fa60d132-0eef-4350-3c88-1558f447a48f@twiddle.net>
Date: Tue, 14 Mar 2017 11:02:37 +1000
MIME-Version: 1.0
In-Reply-To: <20170314003935.2jwycgajo7eojmvm@arch-dev>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Till Smejkal <till.smejkal@googlemail.com>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steven Miao <realmz6@gmail.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andy Lutomirski <luto@amacapital.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Pawel Osciak <pawel@osciak.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Richard Weinberger <richard@nod.at>, Cyrille Pitchen <cyrille.pitchen@atmel.com>, Felipe Balbi <balbi@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Nadia Yvette Chambers <nyc@holomorphy.com>, Jeff Layton <jlayton@poochiereds.net>, "J. Bruce Fields" <bfields@fieldses.org>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-media@vger.kernel.org, linux-mtd@lists.infradead.org, linux-usb@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, alsa-devel@alsa-project.org

On 03/14/2017 10:39 AM, Till Smejkal wrote:
>> Is this an indication that full virtual address spaces are useless?  It
>> would seem like if you only use virtual address segments then you avoid all
>> of the problems with executing code, active stacks, and brk.
>
> What do you mean with *virtual address segments*? The nice part of first class
> virtual address spaces is that one can share/reuse collections of address space
> segments easily.

What do *I* mean?  You introduced the term, didn't you?
Rereading your original I see you called them "VAS segments".

Anyway, whatever they are called, it would seem that these segments do not 
require any of the syncing mechanisms that are causing you problems.


r~

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
