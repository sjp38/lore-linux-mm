Subject: Re: [PATCH 00/30] Swap over NFS -v18
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20080724140042.408642539@chello.nl>
References: <20080724140042.408642539@chello.nl>
Content-Type: text/plain
Date: Tue, 30 Sep 2008 14:41:16 +0200
Message-Id: <1222778476.9044.1.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Neil Brown <neilb@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-07-24 at 16:00 +0200, Peter Zijlstra wrote:
> Latest version of the swap over nfs work.
> 
> Patches are against: v2.6.26-rc8-mm1
> 
> I still need to write some more comments in the reservation code.
> 
> Pekka, it uses ksize(), please have a look.
> 
> This version also deals with network namespaces.
> Two things where I could do with some suggestsion:
> 
>   - currently the sysctl code uses current->nrproxy.net_ns to obtain
>     the current network namespace
> 
>   - the ipv6 route cache code has some initialization order issues

Daniel, have you ever found time to look at my namespace issues?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
