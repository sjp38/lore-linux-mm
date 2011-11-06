Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 77AF16B0069
	for <linux-mm@kvack.org>; Sun,  6 Nov 2011 14:10:25 -0500 (EST)
Subject: Re: [PATCH v2 6/6] slub: only preallocate cpus_with_slabs if
 offstack
From: Pekka Enberg <penberg@kernel.org>
In-Reply-To: <alpine.DEB.2.00.1111020351350.23788@router.home>
References: <1319385413-29665-1-git-send-email-gilad@benyossef.com>
	 <1319385413-29665-7-git-send-email-gilad@benyossef.com>
	 <alpine.DEB.2.00.1110272304020.14619@router.home>
	 <CAOtvUMcHOysen7betBOwEJAjL-UVzvBfCf0fzmmBERFrivkOBA@mail.gmail.com>
	 <alpine.DEB.2.00.1111020351350.23788@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Sun, 06 Nov 2011 21:10:18 +0200
Message-ID: <1320606618.1428.76.camel@jaguar>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>

On Fri, 28 Oct 2011, Gilad Ben-Yossef wrote:
> > I think if it is up to me, I recommend going the simpler  route that
> > does the allocation in flush_all using GFP_ATOMIC for
> > CPUMASK_OFFSTACK=y and sends an IPI to all CPUs if it fails, because
> > it is simpler code and in the end I believe it is also correct.

On Wed, 2011-11-02 at 03:52 -0500, Christoph Lameter wrote:
> I support that. Pekka?

Sure. I'm OK with that. Someone needs to run some tests to make sure
it's working with low memory conditions when GFP_ATOMIC allocations
fail, though.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
