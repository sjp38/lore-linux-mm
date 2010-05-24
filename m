Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3EB4B6B01B0
	for <linux-mm@kvack.org>; Mon, 24 May 2010 03:07:19 -0400 (EDT)
Date: Mon, 24 May 2010 17:07:14 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: oom killer rewrite
Message-ID: <20100524070714.GV2516@laptop>
References: <alpine.DEB.2.00.1005191511140.27294@chino.kir.corp.google.com>
 <20100524100840.1E95.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100524100840.1E95.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, May 24, 2010 at 10:09:34AM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> > KOSAKI,
> > 
> > I've been notified that my entire oom killer rewrite has been dropped from 
> > -mm based solely on your feedback.  The problem is that I have absolutely 
> > no idea what issues you have with the changes that haven't already been 
> > addressed (nobody else does, either, it seems).

I had exactly the same issues with the userland kernel API changes and
the pagefault OOM regression it introduced, which I told you months ago.
You ignored me, it seems.

> 
> That's simple. A regression and an incompatibility are absolutely
> unacceptable. They should be removed. Your patches have some funny parts,
> but, afaik, nobody said funny requirement itself is wrong. They only said
> your requirement don't have to cause any pain to other users.
> 
> Zero risk patches are always acceptable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
