Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id B04856B0260
	for <linux-mm@kvack.org>; Fri, 13 May 2016 11:25:52 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id f14so30487905lbb.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 08:25:52 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id d28si4177093wmi.69.2016.05.13.08.25.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 08:25:51 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id e201so4379094wme.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 08:25:51 -0700 (PDT)
Date: Fri, 13 May 2016 17:25:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
Message-ID: <20160513152549.GU20141@dhcp22.suse.cz>
References: <5731CC6E.3080807@laposte.net>
 <20160513080458.GF20141@dhcp22.suse.cz>
 <573593EE.6010502@free.fr>
 <5735A3DE.9030100@laposte.net>
 <20160513120042.GK20141@dhcp22.suse.cz>
 <5735CAE5.5010104@laposte.net>
 <935da2a3-1fda-bc71-48a5-bb212db305de@gmail.com>
 <5735D7FC.3070409@laposte.net>
 <20160513160142.2cc7d695@lxorguk.ukuu.org.uk>
 <5735EF8E.4000707@laposte.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5735EF8E.4000707@laposte.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Frias <sf84@laposte.net>
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, "Austin S. Hemmelgarn" <ahferroin7@gmail.com>, Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 13-05-16 17:15:26, Sebastian Frias wrote:
> Hi Alan,
> 
> On 05/13/2016 05:01 PM, One Thousand Gnomes wrote:
> > On Fri, 13 May 2016 15:34:52 +0200
> > Sebastian Frias <sf84@laposte.net> wrote:
> > 
> >> Hi Austin,
> >>
> >> On 05/13/2016 03:11 PM, Austin S. Hemmelgarn wrote:
> >>> On 2016-05-13 08:39, Sebastian Frias wrote:  
> >>>>
> >>>> My point is that it seems to be possible to deal with such conditions in a more controlled way, ie: a way that is less random and less abrupt.  
> >>> There's an option for the OOM-killer to just kill the allocating task instead of using the scoring heuristic.  This is about as deterministic as things can get though.  
> >>
> >> By the way, why does it has to "kill" anything in that case?
> >> I mean, shouldn't it just tell the allocating task that there's not enough memory by letting malloc return NULL?
> > 
> > Just turn off overcommit and it will do that. With overcommit disabled
> > the kernel will not hand out address space in excess of memory plus swap.
> 
> I think I'm confused.
> Michal just said:
> 
>    "And again, overcommit=never doesn't imply no-OOM. It just makes it less
> likely. The kernel can consume quite some unreclaimable memory as well."
> 
> which I understand as the OOM-killer will still lurk around and could still wake up.
> 
> Will overcommit=never totally disable the OOM-Killer or not?

Please have a look at __vm_enough_memory and which allocations are
accounted. There are lots of those in kernel which are not accounted so
the OOM killer still might be invoked if there is an excessive in kernel
unreclaimable memory consumer.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
