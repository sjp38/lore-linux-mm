Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 562F86B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 13:51:39 -0500 (EST)
Date: Wed, 24 Nov 2010 10:51:26 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: mmotm 2010-11-23-16-12 uploaded (olpc)
Message-Id: <20101124105126.8248fc1f.randy.dunlap@oracle.com>
In-Reply-To: <201011240045.oAO0jYQ5016010@imap1.linux-foundation.org>
References: <201011240045.oAO0jYQ5016010@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, Daniel Drake <dsd@laptop.org>, Andres Salomon <dilinger@debian.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Nov 2010 16:13:06 -0800 akpm@linux-foundation.org wrote:

> The mm-of-the-moment snapshot 2010-11-23-16-12 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/
> 
> and will soon be available at
> 
>    git://zen-kernel.org/kernel/mmotm.git


make[4]: *** No rule to make target `arch/x86/platform/olpc/olpc-xo1-wakeup.c', needed by `arch/x86/platform/olpc/olpc-xo1-wakeup.o'.


It's olpc-xo1-wakeup.S, so I guess it needs a special makefile rule ??

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
