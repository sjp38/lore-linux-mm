Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0563160021B
	for <linux-mm@kvack.org>; Wed, 30 Dec 2009 19:46:57 -0500 (EST)
Subject: Re: ACPI warning from alloc_pages_nodemask on boot (2.6.33
 regression)
From: Zhang Rui <rui.zhang@intel.com>
In-Reply-To: <20091230100519.5a72d82c@nehalam>
References: <20091229094202.25818e9b@nehalam>
	 <alpine.LFD.2.00.0912291435070.14938@localhost.localdomain>
	 <2f11576a0912292221r7ba59e9dw431c7b43b578a04@mail.gmail.com>
	 <1262187344.7135.230.camel@laptop>  <20091230100519.5a72d82c@nehalam>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 31 Dec 2009 08:47:37 +0800
Message-ID: <1262220457.12263.1403.camel@rzhang1-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Stephen Hemminger <shemminger@vyatta.com>
Cc: Peter Zijlstra <peterz@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Len Brown <lenb@kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-12-31 at 02:05 +0800, Stephen Hemminger wrote:
> On Wed, 30 Dec 2009 16:35:44 +0100
> Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > On Wed, 2009-12-30 at 15:21 +0900, KOSAKI Motohiro wrote:
> > > >> [    1.630020] ------------[ cut here ]------------
> > > >> [    1.630026] WARNING: at mm/page_alloc.c:1812 __alloc_pages_nodemask+0x617/0x730()
> > > >
> > > >        if (order >= MAX_ORDER) {
> > > >                WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
> > > >                return NULL;
> > > >        }
> > > >
> > > > I don't know what the mm alloc code is complaining about here.
> > 
> > > >> [    1.630028] Hardware name: System Product Name
> > > >> [    1.630029] Modules linked in:
> > > >> [    1.630032] Pid: 1, comm: swapper Not tainted 2.6.33-rc2 #4
> > > >> [    1.630034] Call Trace:
> > 
> > > >> [    1.630064]  [<ffffffff812cae3e>] acpi_os_allocate+0x25/0x27 
> > 
> > Right, so ACPI is trying to allocate something larger than 2^MAX_ORDER
> > pages, which on x86 computes to 4K * 2^11 = 8M.
> > 
> > That's not going to work.
> > 
> > Did this machine properly boot before? I seem to remember people working
> > on moving away from bootmem and getting th page/slab stuff up and
> > running sooner, it might be fallout from that...
> > 
> 
> Yes, and it still boots now.
> 
we have rootcaused the problem.
please refer to http://bugzilla.kernel.org/show_bug.cgi?id=14954

thanks,
rui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
