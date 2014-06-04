Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id B65176B0075
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 17:46:11 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id a1so117068wgh.15
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 14:46:11 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ez4si37584864wib.65.2014.06.04.14.46.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Jun 2014 14:46:10 -0700 (PDT)
Date: Wed, 4 Jun 2014 17:45:53 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
Message-ID: <20140604214553.GV2878@cmpxchg.org>
References: <20140528134905.GF2878@cmpxchg.org>
 <20140528142144.GL9895@dhcp22.suse.cz>
 <20140528152854.GG2878@cmpxchg.org>
 <20140528155414.GN9895@dhcp22.suse.cz>
 <20140528163335.GI2878@cmpxchg.org>
 <20140603110743.GD1321@dhcp22.suse.cz>
 <20140603142249.GP2878@cmpxchg.org>
 <20140604144658.GB17612@dhcp22.suse.cz>
 <20140604154408.GT2878@cmpxchg.org>
 <alpine.LSU.2.11.1406041218080.9583@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1406041218080.9583@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On Wed, Jun 04, 2014 at 12:18:59PM -0700, Hugh Dickins wrote:
> On Wed, 4 Jun 2014, Johannes Weiner wrote:
> > On Wed, Jun 04, 2014 at 04:46:58PM +0200, Michal Hocko wrote:
> > > 
> > > In the other email I have suggested to add a knob with the configurable
> > > default. Would you be OK with that?
> > 
> > No, I want to agree on whether we need that fallback code or not.  I'm
> > not interested in merging code that you can't convince anybody else is
> > needed.
> 
> I for one would welcome such a knob as Michal is proposing.

Now we have a tie :-)

> I thought it was long ago agreed that the low limit was going to fallback
> when it couldn't be satisfied.  But you seem implacably opposed to that
> as default, and I can well believe that Google is so accustomed to OOMing
> that it is more comfortable with OOMing as the default.  Okay.  But I
> would expect there to be many who want the attempt towards isolation that
> low limit offers, without a collapse to OOM at the first misjudgement.

At the same time, I only see users like Google pushing the limits of
the machine to a point where guarantees cover north of 90% of memory.
I would expect more casual users to work with much smaller guarantees,
and a good chunk of slack on top - otherwise they already had better
be set up for the occasional OOM.  Is this an unreasonable assumption
to make?

I'm not opposed to this feature per se, but I'm really opposed to
merging it for the partial hard bindings argument and for papering
over deficiencies in our reclaim code, because I don't want any of
that in the changelog, in the documentation, or in what we otherwise
tell users about it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
