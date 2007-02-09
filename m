Received: by nf-out-0910.google.com with SMTP id c2so1129110nfe
        for <linux-mm@kvack.org>; Fri, 09 Feb 2007 07:34:17 -0800 (PST)
From: Alon Bar-Lev <alon.barlev@gmail.com>
Subject: [PATCH 00/34] __initdata cleanup
Date: Fri, 9 Feb 2007 17:11:32 +0200
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200702091711.34441.alon.barlev@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, akpm@osdl.org, bwalle@suse.de, rmk+lkml@arm.linux.org.uk, spyro@f2s.comrmk+lkml@arm.linux.org.uk, davej@codemonkey.org.uk, hpa@zytor.com, Riley@williams.name, tony.luck@intel.com, geert@linux-m68k.org, zippel@linux-m68k.org, ralf@linux-mips.org, matthew@wil.cx, grundler@parisc-linux.org, kyle@parisc-linux.org, paulus@samba.orgpaulus@samba.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, lethal@linux-sh.org, davem@davemloft.net, uclinux-v850@lsi.nec.co.jp, ak@muc.de, vojtech@suse.cz, chris@zankel.net, len.brown@intel.com, lenb@kernel.org, herbert@gondor.apana.org.audavem@davemloft.net, viro@zeniv.linux.org.uk, bzolnier@gmail.com, dmitry.torokhov@gmail.com, dtor@mail.ru, jgarzik@pobox.com, linux-mm@kvack.org, dwmw2@infradead.org, patrick@tykepenguin.comdavem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org, philb@gnu.org, tim@cyberelk.net, andrea@suse.de, ambx1@neo.rr.com, James.Bottomley@steeleye.com, linux-serial@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Follow-up Russell King comment at http://lkml.org/lkml/2007/1/22/267

All __initdata variables should be initialized so they won't end up
in BSS.

There is no dependency between patches or even hunks.

Some architecture patches are untested, this is documented as "UNTESTED"

Against 2.6.20-rc6-mm3.

Signed-off-by: Alon Bar-Lev <alon.barlev@gmail.com>
Signed-off-by: Bernhard Walle <bwalle@suse.de>

---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
