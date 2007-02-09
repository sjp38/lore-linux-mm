Date: Fri, 9 Feb 2007 18:37:34 +0100 (CET)
From: Roman Zippel <zippel@linux-m68k.org>
Subject: Re: [PATCH 00/34] __initdata cleanup
In-Reply-To: <20070209170005.GA8500@osiris.ibm.com>
Message-ID: <Pine.LNX.4.64.0702091831150.14457@scrub.home>
References: <200702091711.34441.alon.barlev@gmail.com> <20070209170005.GA8500@osiris.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Alon Bar-Lev <alon.barlev@gmail.com>, linux-kernel@vger.kernel.org, akpm@osdl.org, bwalle@suse.de, rmk+lkml@arm.linux.org.uk, spyro@f2s.com, davej@codemonkey.org.uk, hpa@zytor.com, Riley@williams.name, tony.luck@intel.com, geert@linux-m68k.org, ralf@linux-mips.org, matthew@wil.cx, grundler@parisc-linux.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, davem@davemloft.net, uclinux-v850@lsi.nec.co.jp, ak@muc.de, vojtech@suse.cz, chris@zankel.net, len.brown@intel.com, lenb@kernel.org, herbert@gondor.apana.org.au, viro@zeniv.linux.org.uk, bzolnier@gmail.com, dmitry.torokhov@gmail.com, dtor@mail.ru, jgarzik@pobox.com, linux-mm@kvack.org, dwmw2@infradead.org, patrick@tykepenguin.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org, philb@gnu.org, tim@cyberelk.net, andrea@suse.de, ambx1@neo.rr.com, James.Bottomley@steeleye.com, linux-serial@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 9 Feb 2007, Heiko Carstens wrote:

> And indeed all the __initdata annotated local and global variables on
> s390 are in the init.data section. So I'm wondering what this patch
> series is about. Or I must have missed something.

I think it reaches back to times when gcc 2.7.* was still supported, which 
does behave as described in the documentation. gcc 2.95 and newer don't 
require explicit initialization anymore, so this has become a non-issue.

bye, Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
