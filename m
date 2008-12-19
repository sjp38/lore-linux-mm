Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 530A06B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 15:25:11 -0500 (EST)
Date: Fri, 19 Dec 2008 21:27:16 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Corruption with O_DIRECT and unaligned user buffers
Message-ID: <20081219202716.GA6383@random.random>
References: <491DAF8E.4080506@quantum.com> <200811191526.00036.nickpiggin@yahoo.com.au> <20081119165819.GE19209@random.random> <20081218152952.GW24856@random.random> <20081219161911.dcf15331.kamezawa.hiroyu@jp.fujitsu.com> <494B50C9.7080308@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <494B50C9.7080308@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Tim LaBerge <tim.laberge@quantum.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, FNST-Wang Chen <wangchen@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hello,

On Fri, Dec 19, 2008 at 03:44:09PM +0800, Li Zefan wrote:
> Tim LaBerge, though the program can pass but sometimes hanged. strace log is
> attached, and we'll test it again with LOCKDEP enabled to see if we can get
> some other information.

So my current suggestion on this is to understand why __reclaim_stacks
is not starting with a lll_unlock before the list_for_each runs, I'll
look into this next week if nobody explained it yet ;). Statistically
speaking it's more likely to be the kernel patch to be buggy and this
is likely a faulty theory I know, but it's not impossible that this is
an unrelated bug that was hidden as it required userland
list_del/add/splice to race against the kernel ptep_set_wrprotect
single instruction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
