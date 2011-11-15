Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 19F9D6B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 11:08:04 -0500 (EST)
Date: Tue, 15 Nov 2011 10:07:57 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [rfc 01/18] slub: Get rid of the node field
In-Reply-To: <CAOJsxLFM9W=NiGFwjt8-iwrTYrAZiJ2_Mw_EUYyXYE4TKPs9-A@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1111151006130.22502@router.home>
References: <20111111200711.156817886@linux.com> <20111111200725.634567005@linux.com> <CAOJsxLFM9W=NiGFwjt8-iwrTYrAZiJ2_Mw_EUYyXYE4TKPs9-A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

On Mon, 14 Nov 2011, Pekka Enberg wrote:

> On Fri, Nov 11, 2011 at 10:07 PM, Christoph Lameter <cl@linux.com> wrote:
> > The node field is always page_to_nid(c->page). So its rather easy to
> > replace. Note that there will be additional overhead in various hot paths
> > due to the need to mask a set of bits in page->flags and shift the
> > result.
> >
> > Signed-off-by: Christoph Lameter <cl@linux.com>
>
> This is a nice cleanup even if we never go irqless in the slowpaths.
> Is page_to_nid() really that slow?

The fastpath only uses a few cycles now. Relatively high overhead is
added.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
