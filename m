Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id AC0A56B00A8
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 17:37:56 -0500 (EST)
Date: Tue, 3 Jan 2012 14:37:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 8/8] mm: add vmstat counters for tracking PCP drains
Message-Id: <20120103143754.f2640d24.akpm@linux-foundation.org>
In-Reply-To: <CAOtvUMc259XZ5BdOqys3Kbv_u=Qa0matnuFyGrJhMPLtRKKkUA@mail.gmail.com>
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
	<1325499859-2262-9-git-send-email-gilad@benyossef.com>
	<4F033F44.6020403@gmail.com>
	<CAOtvUMc259XZ5BdOqys3Kbv_u=Qa0matnuFyGrJhMPLtRKKkUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>

On Tue, 3 Jan 2012 21:00:17 +0200
Gilad Ben-Yossef <gilad@benyossef.com> wrote:

> > NAK.
> >
> > PCP_GLOBAL_IPI_SAVED is only useful at development phase. I can't
> > imagine normal admins use it.
> 
> As the description explains, the purpose of the patch is to show why i
> claim the previous
> patch is useful. I did not meant it to be applied to mainline.

Right.

The thing to do is to use this patch to determine the effectiveness of
the preceding patchset and then present a summary of the results in the
other patch's changelog.  This is precisely what you did and the
results look pretty good.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
