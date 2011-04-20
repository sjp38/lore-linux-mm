Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D376B8D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 09:58:14 -0400 (EDT)
Date: Wed, 20 Apr 2011 08:58:10 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
In-Reply-To: <20110420112020.GA31296@parisc-linux.org>
Message-ID: <alpine.DEB.2.00.1104200855050.8634@router.home>
References: <20110420102314.4604.A69D9226@jp.fujitsu.com> <BANLkTi=mxWwLPEnB+rGg29b06xNUD0XvsA@mail.gmail.com> <20110420161615.462D.A69D9226@jp.fujitsu.com> <BANLkTimfpY3gq8oY6bPDajBW7JN6Hp+A0A@mail.gmail.com> <20110420112020.GA31296@parisc-linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: Pekka Enberg <penberg@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>, Mel Gorman <mel@csn.ul.ie>

On Wed, 20 Apr 2011, Matthew Wilcox wrote:

> On Wed, Apr 20, 2011 at 10:34:23AM +0300, Pekka Enberg wrote:
> > That part makes me think the best option is to make parisc do
> > CONFIG_NUMA as well regardless of the historical intent was.
>
> But it's not just parisc.  It's six other architectures as well, some
> of which aren't even SMP.  Does !SMP && NUMA make any kind of sense?

Of course not.

> I think really, this is just a giant horrible misunderstanding on the part
> of the MM people.  There's no reason why an ARM chip with 16MB of memory
> at 0 and 16MB of memory at 1GB should be saddled with all the NUMA gunk.

DISCONTIG has fallen out of favor in the last years. SPARSEMEM has largely
replaced it. ARM uses that and does not suffer from these issue.

No one considered the issues of having a !NUMA configuration with
nodes (which DISCONTIG seems to create) when developing core code in the
last years. The implicit assumption has always been that page_to_nid(x)
etc is always zero on a !NUMA configuration.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
