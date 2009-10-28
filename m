Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 729F66B0044
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 04:10:32 -0400 (EDT)
Date: Wed, 28 Oct 2009 08:10:35 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: Memory overcommit
In-Reply-To: <alpine.DEB.2.00.0910272111400.8988@chino.kir.corp.google.com>
Message-ID: <Pine.LNX.4.64.0910280801240.20397@sister.anvils>
References: <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0910271843510.11372@sister.anvils> <20091028113713.FD85.A69D9226@jp.fujitsu.com>
 <alpine.DEB.2.00.0910272111400.8988@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, vedran.furac@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Oct 2009, David Rientjes wrote:
> 
> Not sure where the -stable reference came from, I don't think this is a 
> candidate.

I agree with David, this is only one little piece of a messy puzzle,
there's no good reason to rush this into -stable.

> > +	if (has_capability_noaudit(p, CAP_SYS_ADMIN) ||
> > +	    has_capability_noaudit(p, CAP_SYS_RESOURCE) ||
> > +	    has_capability_noaudit(p, CAP_SYS_RAWIO))
> 
> Acked-by: David Rientjes <rientjes@google.com>

Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

(as far as it goes: the whole thing of quartering badness here
because "we don't want to kill" and "important" is questionable;
but definitely much more open to argument both ways than sixteenthing).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
