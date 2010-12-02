Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B81CF6B0085
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 04:43:07 -0500 (EST)
In-reply-to: <20101202091552.4a63f717@xenia.leun.net> (message from Michael
	Leun on Thu, 2 Dec 2010 09:15:52 +0100)
Subject: Re: kernel BUG at mm/truncate.c:475!
References: <20101130194945.58962c44@xenia.leun.net>
	<alpine.LSU.2.00.1011301453090.12516@tigran.mtv.corp.google.com>
	<E1PNjsI-0005Bk-NB@pomaz-ex.szeredi.hu>
	<20101201124528.6809c539@xenia.leun.net>
	<E1PNqO1-0005px-9h@pomaz-ex.szeredi.hu>
	<20101202084159.6bff7355@xenia.leun.net> <20101202091552.4a63f717@xenia.leun.net>
Message-Id: <E1PO5gh-00079U-Ma@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 02 Dec 2010 10:42:51 +0100
Sender: owner-linux-mm@kvack.org
To: Michael Leun <lkml20101129@newton.leun.net>
Cc: miklos@szeredi.hu, hughd@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2 Dec 2010, Michael Leun wrote:
> > Kernel compile 2.6.36.1 with that .page_mkwrite commented out running
> > now, will reboot really soon now (TM).
> 
> OK - that happened very fast again in 2.6.36.1.
> 
> Sorry for that tainted kernel, but cannot afford to additionally have
> graphics lockups all the time - I've shown that it happens with
> untainted kernel also (long run without fault yesterday also was with
> nvidia.ko driver).
> 
> Until I've another suggestion what to try I'll swich back to 2.6.36 to
> see if it really happens less frequent there.

Can you please describe in detail the workload that's causing this to
happen?

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
