Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0527B6B0005
	for <linux-mm@kvack.org>; Fri, 13 May 2016 11:02:03 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id ga2so30132899lbc.0
        for <linux-mm@kvack.org>; Fri, 13 May 2016 08:02:02 -0700 (PDT)
Received: from lxorguk.ukuu.org.uk (lxorguk.ukuu.org.uk. [81.2.110.251])
        by mx.google.com with ESMTPS id ko8si22554303wjc.212.2016.05.13.08.02.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 08:02:01 -0700 (PDT)
Date: Fri, 13 May 2016 16:01:42 +0100
From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
Message-ID: <20160513160142.2cc7d695@lxorguk.ukuu.org.uk>
In-Reply-To: <5735D7FC.3070409@laposte.net>
References: <5731CC6E.3080807@laposte.net>
	<20160513080458.GF20141@dhcp22.suse.cz>
	<573593EE.6010502@free.fr>
	<5735A3DE.9030100@laposte.net>
	<20160513120042.GK20141@dhcp22.suse.cz>
	<5735CAE5.5010104@laposte.net>
	<935da2a3-1fda-bc71-48a5-bb212db305de@gmail.com>
	<5735D7FC.3070409@laposte.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Frias <sf84@laposte.net>
Cc: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>, Michal Hocko <mhocko@kernel.org>, Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 13 May 2016 15:34:52 +0200
Sebastian Frias <sf84@laposte.net> wrote:

> Hi Austin,
> 
> On 05/13/2016 03:11 PM, Austin S. Hemmelgarn wrote:
> > On 2016-05-13 08:39, Sebastian Frias wrote:  
> >>
> >> My point is that it seems to be possible to deal with such conditions in a more controlled way, ie: a way that is less random and less abrupt.  
> > There's an option for the OOM-killer to just kill the allocating task instead of using the scoring heuristic.  This is about as deterministic as things can get though.  
> 
> By the way, why does it has to "kill" anything in that case?
> I mean, shouldn't it just tell the allocating task that there's not enough memory by letting malloc return NULL?

Just turn off overcommit and it will do that. With overcommit disabled
the kernel will not hand out address space in excess of memory plus swap.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
