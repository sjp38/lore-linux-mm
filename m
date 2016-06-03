Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 446EA6B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 23:52:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b124so87755645pfb.1
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 20:52:45 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id wz9si2926535pab.19.2016.06.02.20.52.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 20:52:44 -0700 (PDT)
Date: Fri, 3 Jun 2016 13:52:38 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: BUG: scheduling while atomic: cron/668/0x10c9a0c0
Message-ID: <20160603135238.2657c1b7@canb.auug.org.au>
In-Reply-To: <20160602114341.e3b974640fc3f8cbcb54898b@linux-foundation.org>
References: <CAMuHMdV00vJJxoA7XABw+mFF+2QUd1MuQbPKKgkmGnK_NySZpg@mail.gmail.com>
	<20160530155644.GP2527@techsingularity.net>
	<574E05B8.3060009@suse.cz>
	<20160601091921.GT2527@techsingularity.net>
	<574EB274.4030408@suse.cz>
	<20160602103936.GU2527@techsingularity.net>
	<0eb1f112-65d4-f2e5-911e-697b21324b9f@suse.cz>
	<20160602121936.GV2527@techsingularity.net>
	<20160602114341.e3b974640fc3f8cbcb54898b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Geert Uytterhoeven <geert@linux-m68k.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-m68k <linux-m68k@vger.kernel.org>

Hi Andrew,

On Thu, 2 Jun 2016 11:43:41 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Thu, 2 Jun 2016 13:19:36 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:
> 
> > > >Signed-off-by: Mel Gorman <mgorman@techsingularity.net>  
> > > 
> > > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> > >   
> > 
> > Thanks.  
> 
> I queued this.  A tested-by:Geert would be nice?
> 
> 
> From: Mel Gorman <mgorman@techsingularity.net>
> Subject: mm, page_alloc: recalculate the preferred zoneref if the context can ignore memory policies

I dumped that into linux-next today as well.

-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
