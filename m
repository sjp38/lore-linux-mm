Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 01C176B00BA
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 13:58:47 -0400 (EDT)
Date: Wed, 3 Nov 2010 12:58:45 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 1/3] Linux/Guest unmapped page cache control
In-Reply-To: <20101103171733.GP3769@balbir.in.ibm.com>
Message-ID: <alpine.DEB.2.00.1011031257250.16107@router.home>
References: <20101028224002.32626.13015.sendpatchset@localhost.localdomain> <20101028224008.32626.69769.sendpatchset@localhost.localdomain> <alpine.DEB.2.00.1011030932260.10599@router.home> <20101103171733.GP3769@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Nov 2010, Balbir Singh wrote:

> > > +#define UNMAPPED_PAGE_RATIO 16
> >
> > Maybe come up with a scheme that allows better configuration of the
> > mininum? I think in some setting we may want an absolute limit and in
> > other a fraction of something (total zone size or working set?)
> >
>
> Are you suggesting a sysctl or computation based on zone size and
> limit, etc? I understand it to be the latter.

Do a computation based on zone size on startup and then allow the
user to modify the absolute size of the page cache?


Hmmm.. That would have to be per zone/node or somehow distributed over all
zones/nodes.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
