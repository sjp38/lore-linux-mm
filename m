Date: Tue, 13 May 2003 13:10:09 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.69-mm4
Message-Id: <20030513131009.5e80913a.akpm@digeo.com>
In-Reply-To: <200305130843.20737.tomlins@cam.org>
References: <20030512225504.4baca409.akpm@digeo.com>
	<20030513001135.2395860a.akpm@digeo.com>
	<87n0hr8edh.fsf@lapper.ihatent.com>
	<200305130843.20737.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Tomlinson <tomlins@cam.org> wrote:
>
> > kernel/built-in.o(.text+0x1005): In function `schedule':
>  > : undefined reference to `active_load_balance'
>  >
>  > make: *** [.tmp_vmlinux1] Error 1
>  > alexh@lapper ~/src/linux/linux-2.5.69-mm4 $
> 
>  This happens here too on a tree that was mrproper(ed).

Yeah, I screwed up, sorry.   One of the scheduler patches
was doing kooky things with CONFIG variables.

You can revert sched_idle-typo-fix.patch and sched-2.5.68-B2.patch or build
an SMP kernel or wait for mm5 or kick me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
