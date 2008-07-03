Date: Thu, 3 Jul 2008 02:02:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm] build failure on x86_64 pci-calgary_64.c
Message-Id: <20080703020203.02cd14d4.akpm@linux-foundation.org>
In-Reply-To: <20080703174027.D6D7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <486C74B1.3000007@cn.fujitsu.com>
	<20080703161028.D6CC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080703174027.D6D7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Yinghai Lu <yhlu.kernel@gmail.com>, Ingo Molnar <mingo@elte.hu>, Li Zefan <lizf@cn.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik Van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 03 Jul 2008 17:46:42 +0900 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > > Seems the problematic patch is :
> > > mmap-handle-mlocked-pages-during-map-remap-unmap.patch
> > > 
> > > I'm using mmotm uploaded yesterday by Andrew, so I guess this bug
> > > has not been fixed ?
> > > 
> > > BUG: sleeping function called from invalid context at include/linux/pagemap.h:290
> > > in_atomic():1, irqs_disabled():0
> > 
> > sorry for that.
> > I started investigate this problem.
> 
> Hi Andrew,
> 
> on ia64, I can't reproduce this problem.
> on x86_64, I can't build kernel because following error happned.
>            (end_pfn doesn't exist, but used)
> 
> 
> -----------------------------------------------------
> % LANG=C make -j 20
>   CHK     include/linux/version.h
>   CHK     include/linux/utsrelease.h
>   CALL    scripts/checksyscalls.sh
>   CHK     include/linux/compile.h
>   CC      arch/x86/kernel/pci-calgary_64.o
> arch/x86/kernel/pci-calgary_64.c: In function 'detect_calgary':
> arch/x86/kernel/pci-calgary_64.c:1413: error: 'end_pfn' undeclared (first use in this function)
> arch/x86/kernel/pci-calgary_64.c:1413: error: (Each undeclared identifier is reported only once
> arch/x86/kernel/pci-calgary_64.c:1413: error: for each function it appears in.)
> make[1]: *** [arch/x86/kernel/pci-calgary_64.o] Error 1
> make: *** [arch/x86/kernel] Error 2
> make: *** Waiting for unfinished jobs....
> make: *** wait: No child processes.  Stop.
> 

yup, thanks, I fixed that. 
ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc8/2.6.26-rc8-mm1
is there now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
