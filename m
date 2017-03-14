From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH 07/13] kernel/fork: Split and export 'mm_alloc' and
 'mm_init'
Date: Tue, 14 Mar 2017 10:18:03 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFB03F4@AcuExch.aculab.com>
References: <20170313221415.9375-1-till.smejkal@gmail.com>
 <20170313221415.9375-8-till.smejkal@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
Return-path: <owner-linux-aio@kvack.org>
In-Reply-To: <20170313221415.9375-8-till.smejkal@gmail.com>
Content-Language: en-US
Sender: owner-linux-aio@kvack.org
To: 'Till Smejkal' <till.smejkal@googlemail.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will
 Deacon <will.deacon@arm.com>, Steven Miao <realmz6@gmail.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@>
Cc: "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>, "alsa-devel@alsa-project.org" <alsa-devel@alsa-project.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-aio@kvack.org" <linux-aio@kvack.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, "adi-buildroot-devel@lists.sourceforge.net" <adi-build>
List-Id: linux-mm.kvack.org

From: Linuxppc-dev Till Smejkal
> Sent: 13 March 2017 22:14
> The only way until now to create a new memory map was via the exported
> function 'mm_alloc'. Unfortunately, this function not only allocates a ne=
w
> memory map, but also completely initializes it. However, with the
> introduction of first class virtual address spaces, some initialization
> steps done in 'mm_alloc' are not applicable to the memory maps needed for
> this feature and hence would lead to errors in the kernel code.
>=20
> Instead of introducing a new function that can allocate and initialize
> memory maps for first class virtual address spaces and potentially
> duplicate some code, I decided to split the mm_alloc function as well as
> the 'mm_init' function that it uses.
>=20
> Now there are four functions exported instead of only one. The new
> 'mm_alloc' function only allocates a new mm_struct and zeros it out. If o=
ne
> want to have the old behavior of mm_alloc one can use the newly introduce=
d
> function 'mm_alloc_and_setup' which not only allocates a new mm_struct bu=
t
> also fully initializes it.
...

That looks like bugs waiting to happen.
You need unchanged code to fail to compile.

	David


--
To unsubscribe, send a message with 'unsubscribe linux-aio' in
the body to majordomo@kvack.org.  For more info on Linux AIO,
see: http://www.kvack.org/aio/
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
