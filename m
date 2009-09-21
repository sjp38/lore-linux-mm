Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1E73C6B00BA
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 04:31:43 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] remove duplicate asm/mman.h files
Date: Mon, 21 Sep 2009 10:31:25 +0200
References: <cover.1251197514.git.ebmunson@us.ibm.com> <200909181848.42192.arnd@arndb.de> <alpine.DEB.1.00.0909181236190.27556@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.1.00.0909181236190.27556@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200909211031.25369.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, ebmunson@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, mtk.manpages@gmail.com, randy.dunlap@oracle.com, rth@twiddle.net, ink@jurassic.park.msu.ru, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Friday 18 September 2009, David Rientjes wrote:
> On Fri, 18 Sep 2009, Arnd Bergmann wrote:
>
> > -#define MCL_CURRENT	1		/* lock all current mappings */
> > -#define MCL_FUTURE	2		/* lock all future mappings */
> > +#define MAP_GROWSUP	0x0200		/* register stack-like segment */
> >  
> >  #ifdef __KERNEL__
> >  #ifndef __ASSEMBLY__
> 
> ia64 doesn't use MAP_GROWSUP, so it's probably not necessary to carry it 
> along with your cleanup.

ia64 is the only architecture defining it, nobody uses it in the kernel.
If the ia64 maintainers want to remove it in a separate patch, that
would probably be a good idea.

I tried not to change the ABI in any way in my patch, and there is
a theoretical possibility that some user space program on ia64 currently
depends on that definition.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
