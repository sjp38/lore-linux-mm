Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 0D88C6B00D6
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 11:04:42 -0500 (EST)
Date: Tue, 17 Jan 2012 10:04:38 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Hung task when calling clone() due to netfilter/slab
In-Reply-To: <1326814208.2259.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Message-ID: <alpine.DEB.2.00.1201170942240.4800@router.home>
References: <1326558605.19951.7.camel@lappy>    <1326561043.5287.24.camel@edumazet-laptop>   <1326632384.11711.3.camel@lappy>  <1326648305.5287.78.camel@edumazet-laptop>   <alpine.DEB.2.00.1201170910130.4800@router.home>  <1326813630.2259.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
  <alpine.DEB.2.00.1201170927020.4800@router.home> <1326814208.2259.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, Dave Jones <davej@redhat.com>, davem <davem@davemloft.net>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, kaber@trash.net, pablo@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>

On Tue, 17 Jan 2012, Eric Dumazet wrote:

> Thanks !
>
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

That may not be the end of it. Slub also calls sysfs from sysfs_add_alias
while holding slub_lock.

If sysfs allows user space stuff to run then you cannot really hold any
locks. How is one supposed to sync adding pointers to sysfs structures in
subsystems? Drop all locks and then recheck the memory structures after
the sysfs function returns? Awkward.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
