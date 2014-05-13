Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7B3806B0037
	for <linux-mm@kvack.org>; Tue, 13 May 2014 10:30:55 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id c13so480992eek.34
        for <linux-mm@kvack.org>; Tue, 13 May 2014 07:30:54 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y41si13280889eel.320.2014.05.13.07.30.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 07:30:54 -0700 (PDT)
Date: Tue, 13 May 2014 15:30:50 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 17/19] fs: buffer: Do not use unnecessary atomic
 operations when discarding buffers
Message-ID: <20140513143050.GU23991@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-18-git-send-email-mgorman@suse.de>
 <20140513110951.GB30445@twins.programming.kicks-ass.net>
 <20140513125007.GQ23991@suse.de>
 <20140513134943.GD22070@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140513134943.GD22070@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Tue, May 13, 2014 at 03:49:43PM +0200, Jan Kara wrote:
> > > operation which is available on a lot of architectures, we'll be stuck
> > > with a cmpxchg loop instead :/
> > > 
> > > *sigh*
> > > 
> > > Anyway, nothing wrong with this patch, however, you could, if you really
> > > wanted to push things, also include BH_Lock in that clear :-)
> > 
> > That's a bold strategy Cotton.
> > 
> > Untested patch on top
>   Although this looks correct, I have to say I prefer the explicit
> unlock_buffer() unless this has a measurable benefit.
> 

I will keep this as a separate patch, move it to the end of the series
and check what the profiles look like. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
