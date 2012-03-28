Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 484D66B007E
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 03:20:36 -0400 (EDT)
Received: by iajr24 with SMTP id r24so1378145iaj.14
        for <linux-mm@kvack.org>; Wed, 28 Mar 2012 00:20:35 -0700 (PDT)
Date: Wed, 28 Mar 2012 00:20:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 10/10] oom: Make find_lock_task_mm() sparse-aware
In-Reply-To: <1332593574.16159.31.camel@twins>
Message-ID: <alpine.DEB.2.00.1203280020100.16201@chino.kir.corp.google.com>
References: <20120324102609.GA28356@lizard> <20120324103127.GJ29067@lizard> <1332593574.16159.31.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Russell King <linux@arm.linux.org.uk>, Mike Frysinger <vapier@gentoo.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Richard Weinberger <richard@nod.at>, Paul Mundt <lethal@linux-sh.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, John Stultz <john.stultz@linaro.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-mm@kvack.org

On Sat, 24 Mar 2012, Peter Zijlstra wrote:

> Yeah, so Nacked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> Also, why didn't lockdep catch it?
> 
> Fix sparse already instead of smearing ugly all over.
> 

Fully agreed, please don't add this to the oom killer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
