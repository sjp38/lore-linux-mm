Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 352646B0253
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 08:46:10 -0400 (EDT)
Received: by wijp15 with SMTP id p15so15139723wij.0
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 05:46:09 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id ce9si12503669wib.4.2015.08.20.05.46.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Aug 2015 05:46:08 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so15147488wic.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 05:46:08 -0700 (PDT)
Date: Thu, 20 Aug 2015 14:46:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 07/10] mm: page_alloc: Rename __GFP_WAIT to __GFP_RECLAIM
Message-ID: <20150820124606.GF20110@dhcp22.suse.cz>
References: <1439376335-17895-1-git-send-email-mgorman@techsingularity.net>
 <1439376335-17895-8-git-send-email-mgorman@techsingularity.net>
 <20150820122857.GC20110@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150820122857.GC20110@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 20-08-15 14:28:57, Michal Hocko wrote:
> On Wed 12-08-15 11:45:32, Mel Gorman wrote:
> > __GFP_WAIT was used to signal that the caller was in atomic context and
> > could not sleep.  Now it is possible to distinguish between true atomic
> > context and callers that are not willing to sleep. The latter should clear
> > __GFP_DIRECT_RECLAIM so kswapd will still wake. As clearing __GFP_WAIT
> > behaves differently, there is a risk that people will clear the wrong
> > flags. This patch renames __GFP_WAIT to __GFP_RECLAIM to clearly indicate
> > what it does -- setting it allows all reclaim activity, clearing them
> > prevents it.
> > 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> 
> I haven't checked all the converted places too deeply but they look
> straightforward.
> 
> Acked-by: Michal Hocko <mhocko@suse.cz>

I meant @suse.com, dang the old one is hardwired into my hands...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
