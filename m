Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 54ADB6B0047
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 10:11:29 -0500 (EST)
Date: Tue, 9 Mar 2010 09:10:52 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: mm: Do not iterate over NR_CPUS in __zone_pcp_update()
In-Reply-To: <4B95AD17.2030106@kernel.org>
Message-ID: <alpine.DEB.2.00.1003090910200.28897@router.home>
References: <alpine.LFD.2.00.1003081018070.22855@localhost.localdomain> <84144f021003080529w1b20c08dmf6871bd46381bc71@mail.gmail.com> <4B95AD17.2030106@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Mar 2010, Tejun Heo wrote:

> Yeap, that's buggy.
>
> Acked-by: Tejun Heo <tj@kernel.org>
>
> I suppose this would go through the mm tree?

As you said: Its a bug so it needs to be applied to upstream.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
