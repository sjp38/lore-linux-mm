Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D255B6B004D
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 08:53:24 -0400 (EDT)
Date: Fri, 16 Oct 2009 14:53:13 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 0/2] x86, UV: fixups for configurations with a large
	number of nodes.
Message-ID: <20091016125313.GB15393@elte.hu>
References: <20091015223959.783988000@alcatraz.americas.sgi.com> <20091016063405.GB20388@elte.hu> <20091016112920.GZ8903@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091016112920.GZ8903@sgi.com>
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Cliff Whickman <cpw@sgi.com>
List-ID: <linux-mm.kvack.org>


* Robin Holt <holt@sgi.com> wrote:

> >   uv_nshift = uv_hub_info->m_val;
> > 
> > to (in essence):
> > 
> >               uv_hub_info->m_val & ((1UL << uv_hub_info->n_val) - 1)
> > 
> > which is not the same. Furthermore, the new inline is:
> 
> You have an excellent point there.  That was a bug as well.  That may 
> explain a few of our currently unexplained bau hangs.  The value is 
> supposed to be a pnode instead of the current gnode.

So ... is the commit log message i've put into the commit below correct, 
or is it still only a cleanup patch? You really need to put that kind of 
info into your changelogs - it helps maintainers put it into the right 
kernel release.

	Ingo

------------>
