Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B8D778D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 13:15:06 -0400 (EDT)
Date: Tue, 19 Apr 2011 12:15:01 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
In-Reply-To: <1303233088.3171.26.camel@mulgrave.site>
Message-ID: <alpine.DEB.2.00.1104191213120.17888@router.home>
References: <20110415135144.GE8828@tiehlicka.suse.cz>  <alpine.LSU.2.00.1104171952040.22679@sister.anvils>  <20110418100131.GD8925@tiehlicka.suse.cz>  <20110418135637.5baac204.akpm@linux-foundation.org>  <20110419111004.GE21689@tiehlicka.suse.cz>
 <1303228009.3171.18.camel@mulgrave.site>  <BANLkTimYrD_Sby_u-fPSwn-RJJyEVavU5w@mail.gmail.com> <1303233088.3171.26.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>

On Tue, 19 Apr 2011, James Bottomley wrote:

> On Tue, 2011-04-19 at 20:05 +0300, Pekka Enberg wrote:
> > > It seems to be a random intermittent mm crash because the next reboot
> > > crashed with the same trace but after the fsck had completed and the
> > > third came up to the login prompt.
> >
> > Looks like a genuine SLUB problem on parisc. Christoph?
>
> Looking through the slub code, it seems to be making invalid
> assumptions.  All of the node stuff is dependent on CONFIG_NUMA.
> However, we're CONFIG_DISCONTIGMEM (with CONFIG_NUMA not set): on the
> machines I and Dave Anglin have, our physical memory ranges are 0-1GB
> and 64-65GB, so I think slub crashes when we get a page from the high
> memory range ... because it's not expecting a non-zero node number.

Right !NUMA systems only have node 0.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
