Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E5D788D0040
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 11:31:11 -0500 (EST)
MIME-Version: 1.0
Message-ID: <7bdfb0e2-fcfd-478f-b9fa-acb90c2ef550@default>
Date: Fri, 4 Feb 2011 08:29:25 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [Xen-devel] [PATCH R3 0/7] xen/balloon: Memory hotplug support
 for Xen balloon driver
References: <20110203162345.GC1364@router-fw-old.local.net-space.pl>
 <1296768009.2346.7.camel@mobile
 1296810682.13091.571.camel@zakaz.uk.xensource.com>
In-Reply-To: <1296810682.13091.571.camel@zakaz.uk.xensource.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian Campbell <Ian.Campbell@eu.citrix.com>, v.tolstov@selfip.ru
Cc: Daniel Kiper <dkiper@net-space.pl>, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, Konrad Wilk <konrad.wilk@oracle.com>, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> From: Ian Campbell [mailto:Ian.Campbell@eu.citrix.com]
> Sent: Friday, February 04, 2011 2:11 AM
>=20
> On Thu, 2011-02-03 at 21:20 +0000, Vasiliy G Tolstov wrote:
> > I have some may be offtopic question: Is that possible to export
> balloon
> > function balloon_set_new_target to GPL modules (EXPORT_SYMBOL_GPL) ?
> > This helps to kernel modules (not in kernel tree) to contol balloonin
> > (for example autoballoon or something else) without needing to write
> so
> > sysfs. (Writing files from kernel module is bad, this says Linux
> Kernel
> > Faq).
>=20
> Is there a reason to do it from kernel space in the first place? auto
> ballooning can be done by a userspace daemon, can't it?

The whole point of self-ballooning is to teach an OS kernel to
be more aggressive about "surrendering" memory that it isn't
using efficiently.  I've called this "memory asceticism".  See
slide 12 in

http://oss.oracle.com/projects/tmem/dist/documentation/presentations/MemMgm=
tVirtEnv-LPC2010-Final.pdf=20

as well as the issues/solutions slides later in that presentation.

And for anyone on this dist list seeing these slides and
concepts for the first time, you can "read" the presentation
with the speaker notes here:

http://oss.oracle.com/projects/tmem/dist/documentation/presentations/MemMgm=
tVirtEnv-LPC2010-SpkNotes.pdf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
