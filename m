Message-ID: <401A3762.5070701@aitel.hist.no>
Date: Fri, 30 Jan 2004 11:52:18 +0100
From: Helge Hafting <helgehaf@aitel.hist.no>
MIME-Version: 1.0
Subject: Re: 2.6.2-rc2-mm2
References: <20040130014108.09c964fd.akpm@osdl.org>
In-Reply-To: <20040130014108.09c964fd.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> 
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.2-rc2/2.6.2-rc2-mm2/
> 
> 
> - I added a few late-arriving patches.  Usually this breaks things.
> 
Indeed, it didn't apply:
patching file include/linux/sched.h
Reversed (or previously applied) patch detected!  Assume -R? [n] N
Apply anyway? [n] N

I unpacked 2.6.0 and patched it up to 2.6.2-rc2 again to be sure.
Everything else applied so I'm compiling that now.

Helge Hafting


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
