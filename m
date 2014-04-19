Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 492E86B0031
	for <linux-mm@kvack.org>; Sat, 19 Apr 2014 07:20:28 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id e49so2341366eek.3
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 04:20:27 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w48si44488535eel.26.2014.04.19.04.20.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 19 Apr 2014 04:20:27 -0700 (PDT)
Date: Sat, 19 Apr 2014 12:19:34 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 08/16] mm: page_alloc: Only check the alloc flags and
 gfp_mask for dirty once
Message-ID: <20140419111934.GC4225@suse.de>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
 <1397832643-14275-9-git-send-email-mgorman@suse.de>
 <20140418180836.GE29210@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140418180836.GE29210@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Fri, Apr 18, 2014 at 02:08:36PM -0400, Johannes Weiner wrote:
> On Fri, Apr 18, 2014 at 03:50:35PM +0100, Mel Gorman wrote:
> > Currently it's calculated once per zone in the zonelist.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> I would have assumed the compiler can detect such a loop invariant...
> Alas,
> 

Surprisingly it didn't in my case but the benefit of the patch is
marginal at best. I can drop it if it makes the code more obscure to
peoples eyes.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
