Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f177.google.com (mail-vc0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id 41B426B0069
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 15:20:26 -0400 (EDT)
Received: by mail-vc0-f177.google.com with SMTP id hy4so6208938vcb.36
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 12:20:26 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id fd2si7689382pbd.177.2014.06.04.12.20.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Jun 2014 12:20:25 -0700 (PDT)
Received: by mail-pd0-f171.google.com with SMTP id y13so6471485pdi.16
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 12:20:25 -0700 (PDT)
Date: Wed, 4 Jun 2014 12:18:59 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
In-Reply-To: <20140604154408.GT2878@cmpxchg.org>
Message-ID: <alpine.LSU.2.11.1406041218080.9583@eggly.anvils>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz> <20140528121023.GA10735@dhcp22.suse.cz> <20140528134905.GF2878@cmpxchg.org> <20140528142144.GL9895@dhcp22.suse.cz> <20140528152854.GG2878@cmpxchg.org> <20140528155414.GN9895@dhcp22.suse.cz>
 <20140528163335.GI2878@cmpxchg.org> <20140603110743.GD1321@dhcp22.suse.cz> <20140603142249.GP2878@cmpxchg.org> <20140604144658.GB17612@dhcp22.suse.cz> <20140604154408.GT2878@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On Wed, 4 Jun 2014, Johannes Weiner wrote:
> On Wed, Jun 04, 2014 at 04:46:58PM +0200, Michal Hocko wrote:
> > 
> > In the other email I have suggested to add a knob with the configurable
> > default. Would you be OK with that?
> 
> No, I want to agree on whether we need that fallback code or not.  I'm
> not interested in merging code that you can't convince anybody else is
> needed.

I for one would welcome such a knob as Michal is proposing.

I thought it was long ago agreed that the low limit was going to fallback
when it couldn't be satisfied.  But you seem implacably opposed to that
as default, and I can well believe that Google is so accustomed to OOMing
that it is more comfortable with OOMing as the default.  Okay.  But I
would expect there to be many who want the attempt towards isolation that
low limit offers, without a collapse to OOM at the first misjudgement.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
