Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id B1C2B6B0258
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 13:17:58 -0500 (EST)
Received: by wmec201 with SMTP id c201so274162076wme.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 10:17:58 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id h5si39089706wmh.56.2015.12.09.10.17.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 10:17:57 -0800 (PST)
Date: Wed, 9 Dec 2015 13:17:46 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 00/14] mm: memcontrol: account socket memory in unified
 hierarchy v4-RESEND
Message-ID: <20151209181746.GA22412@cmpxchg.org>
References: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
 <2564892.qO1q7YJ6Nb@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2564892.qO1q7YJ6Nb@wuerfel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hey Arnd!

On Wed, Dec 09, 2015 at 05:31:38PM +0100, Arnd Bergmann wrote:
> On Tuesday 08 December 2015 10:30:10 Johannes Weiner wrote:
> > Hi Andrew,
> > 
> > there was some build breakage in CONFIG_ combinations I hadn't tested
> > in the last revision, so here is a fixed-up resend with minimal CC
> > list. The only difference to the previous version is a section in
> > memcontrol.h, but it accumulates throughout the series and would have
> > been a pain to resolve on your end. So here goes. This also includes
> > the review tags that Dave and Vlad had sent out in the meantime.
> > 
> > Difference to the original v4:
> 
> I needed two more patches on top of today's linux-next kernel, will
> send them as replies to this mail. I don't know if you have already
> fixed the issues for !CONFIG_INET and CONFIG_SLOB, if not please
> fold them into your series.

Sorry for breaking your stuff, and thanks for sending patches. I'll
get to them in a minute and will make sure the fixes get routed to
Andrew.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
