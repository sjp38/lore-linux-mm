Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 68B916B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 21:30:11 -0400 (EDT)
Date: Wed, 15 Jun 2011 18:29:58 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: mmotm 2011-06-15-16-56 uploaded (UML build error)
Message-Id: <20110615182958.d5aad636.randy.dunlap@oracle.com>
In-Reply-To: <201106160034.p5G0Y4dr028904@imap1.linux-foundation.org>
References: <201106160034.p5G0Y4dr028904@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Wed, 15 Jun 2011 16:56:49 -0700 akpm@linux-foundation.org wrote:

> The mm-of-the-moment snapshot 2011-06-15-16-56 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/
> 
> and will soon be available at
>    git://zen-kernel.org/kernel/mmotm.git
> or
>    git://git.cmpxchg.org/linux-mmotm.git
> 
> It contains the following patches against 3.0-rc3:


When building UML for x86_64 (defconfig), I get:

fs/built-in.o: In function `__bprm_mm_init':
mmotm-2011-0615-1656/fs/exec.c:280: undefined reference to `__build_bug_on_failed'

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
