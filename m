Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AA0CC6B00ED
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 02:48:12 -0500 (EST)
Date: Thu, 2 Dec 2010 08:41:59 +0100
From: Michael Leun <lkml20101129@newton.leun.net>
Subject: Re: kernel BUG at mm/truncate.c:475!
Message-ID: <20101202084159.6bff7355@xenia.leun.net>
In-Reply-To: <E1PNqO1-0005px-9h@pomaz-ex.szeredi.hu>
References: <20101130194945.58962c44@xenia.leun.net>
	<alpine.LSU.2.00.1011301453090.12516@tigran.mtv.corp.google.com>
	<E1PNjsI-0005Bk-NB@pomaz-ex.szeredi.hu>
	<20101201124528.6809c539@xenia.leun.net>
	<E1PNqO1-0005px-9h@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: hughd@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 01 Dec 2010 18:22:33 +0100
Miklos Szeredi <miklos@szeredi.hu> wrote:

> On Wed, 1 Dec 2010, Michael Leun wrote:
> > At the moment I've downgraded to 2.6.36 - I cannot remember to have
> > seen this there - which does not need to mean anything, because
> > workload has changed (several unshared mount/network namespaces
> > chrooted into unionfs-fuse mounted roots - cool stuff...).
> > 
> > Would you suspect to make 2.6.36 <> 2.6.36.1 a difference here?
> 
> No, that's unlikely.

Took until now to happen in 2.6.36 - so it is there also. I cannot
really say if it is less frequent in 2.6.36 at the moment, but from
that very limited number of tests (1) it looks like.

> > Later, when I've results from the test with 2.6.36 of course I'll
> > try the quick test you suggested.
> 
> Okay, thanks.

Kernel compile 2.6.36.1 with that .page_mkwrite commented out running
now, will reboot really soon now (TM).

-- 
MfG,

Michael Leun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
