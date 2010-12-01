Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B43816B0093
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 12:22:56 -0500 (EST)
In-reply-to: <20101201124528.6809c539@xenia.leun.net> (message from Michael
	Leun on Wed, 1 Dec 2010 12:45:28 +0100)
Subject: Re: kernel BUG at mm/truncate.c:475!
References: <20101130194945.58962c44@xenia.leun.net>
	<alpine.LSU.2.00.1011301453090.12516@tigran.mtv.corp.google.com>
	<E1PNjsI-0005Bk-NB@pomaz-ex.szeredi.hu> <20101201124528.6809c539@xenia.leun.net>
Message-Id: <E1PNqO1-0005px-9h@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 01 Dec 2010 18:22:33 +0100
Sender: owner-linux-mm@kvack.org
To: Michael Leun <lkml20101129@newton.leun.net>
Cc: miklos@szeredi.hu, hughd@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 1 Dec 2010, Michael Leun wrote:
> At the moment I've downgraded to 2.6.36 - I cannot remember to have
> seen this there - which does not need to mean anything, because
> workload has changed (several unshared mount/network namespaces chrooted
> into unionfs-fuse mounted roots - cool stuff...).
> 
> Would you suspect to make 2.6.36 <> 2.6.36.1 a difference here?

No, that's unlikely.

> Later, when I've results from the test with 2.6.36 of course I'll try
> the quick test you suggested.

Okay, thanks.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
