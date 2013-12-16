Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 72ACB6B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 03:22:52 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id q10so5014790pdj.25
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 00:22:51 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id g5si8182048pav.288.2013.12.16.00.22.49
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 00:22:51 -0800 (PST)
Date: Mon, 16 Dec 2013 17:22:48 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [patch 2/2] fs: buffer: move allocation failure loop into the
 allocator
Message-ID: <20131216082247.GA5334@lge.com>
References: <1381265890-11333-1-git-send-email-hannes@cmpxchg.org>
 <1381265890-11333-2-git-send-email-hannes@cmpxchg.org>
 <20131203165910.54d6b4724a1f3e329af52ac6@linux-foundation.org>
 <20131204015218.GA19709@lge.com>
 <20131213065805.GC8845@lge.com>
 <00000142ecd51cc6-b987e565-7b4f-4945-89ba-731f1d1376fb-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00000142ecd51cc6-b987e565-7b4f-4945-89ba-731f1d1376fb-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, azurIt <azurit@pobox.sk>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Christian Casteyde <casteyde.christian@free.fr>, Pekka Enberg <penberg@kernel.org>

On Fri, Dec 13, 2013 at 04:40:58PM +0000, Christoph Lameter wrote:
> On Fri, 13 Dec 2013, Joonsoo Kim wrote:
> 
> > Could you review this patch?
> > I think that we should merge it to fix the problem reported by Christian.
> 
> I'd be fine with clearing __GFP_NOFAIL but not with using the same flags
> as for a higher order alloc. __GFP_NORETRY and __GFP_NOWARN should be left
> untouched for the minimal alloc.

Hello.

So you don't want to add __GFP_NORETRY and __GFP_NOWARN for kmemcheck?
I think that it isn't good idea, since users would meet *unexpected*
allocation failure if they enable kmemcheck and slub uses different flags
for kmemcheck. It makes users who want to debug their own problems embarrass.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
