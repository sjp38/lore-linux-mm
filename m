Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id BEFC66B002C
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 11:04:35 -0500 (EST)
Date: Fri, 3 Feb 2012 17:04:31 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] Handling of unused variable 'do-numainfo on compilation
 time
Message-ID: <20120203160431.GB13461@tiehlicka.suse.cz>
References: <1328258627-2241-1-git-send-email-geunsik.lim@gmail.com>
 <20120203133950.GA1690@cmpxchg.org>
 <20120203145304.GA18335@tiehlicka.suse.cz>
 <CAGFP0LK4_PhKLJVtMhsNe4YfUQoHcoTK3hJhHaBy51f359ef7A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGFP0LK4_PhKLJVtMhsNe4YfUQoHcoTK3hJhHaBy51f359ef7A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geunsik Lim <geunsik.lim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel <linux-kernel@vger.kernel.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>

On Sat 04-02-12 00:36:36, Geunsik Lim wrote:
> On Fri, Feb 3, 2012 at 11:53 PM, Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Fri 03-02-12 14:39:50, Johannes Weiner wrote:
> > > Michal, this keeps coming up, please decide between the proposed
> > > solutions ;-)
> >
> > Hmm, I thought we already sorted this out
> > https://lkml.org/lkml/2012/1/26/25 ?
> >
> I don't know previous history about this variable.
> Is it same? Please, adjust this patch or fix the unsuitable
> variable 'do_numainfo' as I mentioned.

The patch (I guess the author is Andrew) just silence the compiler
warning which is the easiest fix in this case because we know it will be
used only for MAX_NUMNODES > 1.
Your patch fixes it as well but it adds an ugly ifdef around the
variable.

Andrew, could you pick up this one, please?
---
