Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BBB6A8D003F
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 11:07:40 -0400 (EDT)
Date: Thu, 17 Mar 2011 15:07:05 +0000
From: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Subject: Re: Bootup fix for _brk_end being != _end
In-Reply-To: <20110317085118.GA11346@router-fw-old.local.net-space.pl>
Message-ID: <alpine.DEB.2.00.1103171504200.3382@kaball-desktop>
References: <20110308214429.GA27331@router-fw-old.local.net-space.pl> <alpine.DEB.2.00.1103091359290.2968@kaball-desktop> <20110315142957.GB12730@router-fw-old.local.net-space.pl> <20110315144821.GA11586@dumpdata.com> <20110315153001.GD12730@router-fw-old.local.net-space.pl>
 <alpine.DEB.2.00.1103151530290.3382@kaball-desktop> <20110315154024.GA14100@router-fw-old.local.net-space.pl> <20110317085118.GA11346@router-fw-old.local.net-space.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: Stefano Stabellini <Stefano.Stabellini@eu.citrix.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Ian Campbell <Ian.Campbell@eu.citrix.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "andi.kleen@intel.com" <andi.kleen@intel.com>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "jeremy@goop.org" <jeremy@goop.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, "v.tolstov@selfip.ru" <v.tolstov@selfip.ru>, "pasik@iki.fi" <pasik@iki.fi>, "dave@linux.vnet.ibm.com" <dave@linux.vnet.ibm.com>, "wdauchy@gmail.com" <wdauchy@gmail.com>, "rientjes@google.com" <rientjes@google.com>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 17 Mar 2011, Daniel Kiper wrote:
> > > > > Details? Can you provide the 'xenctx' output of where it crashed?
> > > >
> > > > As I wrote above domain is dying and I am not able to connect to it using
> > > > xenctx after crash :-(((. I do not know how to do that in another way.
> > >
> > > try adding:
> > >
> > > extra = "loglevel=9 debug earlyprintk=xenboot"
> >
> > (XEN) d55:v0: unhandled page fault (ec=0002)
> > (XEN) Pagetable walk from 000000000000000c:
> > (XEN)  L4[0x000] = 000000010bebc027 0000000000024d28
> > (XEN)  L3[0x000] = 0000000000000000 ffffffffffffffff
> > (XEN) domain_crash_sync called from entry.S
> > (XEN) Domain 55 (vcpu#0) crashed on cpu#3:
> > (XEN) ----[ Xen-4.1.0-rc2-pre  x86_64  debug=y  Not tainted ]----
> > (XEN) CPU:    3
> > (XEN) RIP:    e019:[<00000000c1001180>]
> > (XEN) RFLAGS: 0000000000000282   EM: 1   CONTEXT: pv guest
> > (XEN) rax: 000000000000000c   rbx: 000000000000000c   rcx: 00000000c1371fd0
> > (XEN) rdx: 00000000c1371fd0   rsi: 00000000c1742000   rdi: 00000000a5c03d70
> > (XEN) rbp: 00000000c1371fc8   rsp: 00000000c1371fa8   r8: 0000000000000000
> > (XEN) r9:  0000000000000000   r10: 0000000000000000   r11: 0000000000000000
> > (XEN) r12: 0000000000000000   r13: 0000000000000000   r14: 0000000000000000
> > (XEN) r15: 0000000000000000   cr0: 000000008005003b   cr4: 00000000000026f4
> > (XEN) cr3: 0000000129b6e000   cr2: 000000000000000c
> > (XEN) ds: e021   es: e021   fs: e021   gs: e021   ss: e021   cs: e019
> > (XEN) Guest stack trace from esp=c1371fa8:
> > (XEN)   00000002 c1001180 0001e019 00010082 c10037af deadbeef c1742000 a5c03d70
> > (XEN)   c1371fdc c13a4aa8 00000000 00000000 00000000 c1371ffc c13a3ff2 00000000
> > (XEN)   00000000 00000000 00000000 00000000 deadbeef c1753000 013fe001 00000000
> > (XEN)   00000000 00000000 00000000 00000000 013fe001 00000000 00000000 00000000
> > (XEN)   00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> > (XEN)   00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> > (XEN)   00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> > (XEN)   00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> > (XEN)   00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> > (XEN)   00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> > (XEN)   00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> > (XEN)   00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> > (XEN)   00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> > (XEN)   00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> > (XEN)   00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> > (XEN)   00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> > (XEN)   00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> > (XEN)   00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> > (XEN)   00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> > (XEN)   00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> 
> Any progress ??? Can I help you in something ???
> 
 
Unfortunately unless you are able to resolve the IP of the crash these
logs don't tell me much.
Alternatively you can try to get more infos using /usr/lib/xen/bin/xenctx
like Konrad suggested.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
