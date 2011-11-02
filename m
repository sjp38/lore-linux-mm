Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E6F736B0069
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 04:52:08 -0400 (EDT)
Date: Wed, 2 Nov 2011 03:52:04 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH v2 6/6] slub: only preallocate cpus_with_slabs if
 offstack
In-Reply-To: <CAOtvUMcHOysen7betBOwEJAjL-UVzvBfCf0fzmmBERFrivkOBA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1111020351350.23788@router.home>
References: <1319385413-29665-1-git-send-email-gilad@benyossef.com> <1319385413-29665-7-git-send-email-gilad@benyossef.com> <alpine.DEB.2.00.1110272304020.14619@router.home> <CAOtvUMcHOysen7betBOwEJAjL-UVzvBfCf0fzmmBERFrivkOBA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>

On Fri, 28 Oct 2011, Gilad Ben-Yossef wrote:

> I think if it is up to me, I recommend going the simpler  route that
> does the allocation in flush_all using GFP_ATOMIC for
> CPUMASK_OFFSTACK=y and sends an IPI to all CPUs if it fails, because
> it is simpler code and in the end I believe it is also correct.

I support that. Pekka?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
