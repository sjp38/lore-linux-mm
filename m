Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 98D058D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 12:51:03 -0400 (EDT)
Date: Wed, 20 Apr 2011 11:50:58 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
In-Reply-To: <1303317178.2587.30.camel@mulgrave.site>
Message-ID: <alpine.DEB.2.00.1104201149520.12154@router.home>
References: <20110420161615.462D.A69D9226@jp.fujitsu.com>  <BANLkTimfpY3gq8oY6bPDajBW7JN6Hp+A0A@mail.gmail.com>  <20110420174027.4631.A69D9226@jp.fujitsu.com> <1303317178.2587.30.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>

On Wed, 20 Apr 2011, James Bottomley wrote:

> > > That part makes me think the best option is to make parisc do
> > > CONFIG_NUMA as well regardless of the historical intent was.

Well if it never supported NUMA then this is going to be problematic.
> > >
> > >                         Pekka
> >
> > This?
>
> I'm afraid it doesn't boot (it's another slub crash):

Is there any simulator available that we can use to run a parisc boot?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
