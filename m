Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1896B0038
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 08:01:49 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id qs7so86948102wjc.4
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 05:01:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m70si1862511wmg.143.2017.01.10.05.01.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Jan 2017 05:01:48 -0800 (PST)
Date: Tue, 10 Jan 2017 14:01:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, thp: add new background defrag option
Message-ID: <20170110130146.GF28025@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1701041532040.67903@chino.kir.corp.google.com>
 <20170105101330.bvhuglbbeudubgqb@techsingularity.net>
 <fe83f15e-2d9f-e36c-3a89-ce1a2b39e3ca@suse.cz>
 <alpine.DEB.2.10.1701051446140.19790@chino.kir.corp.google.com>
 <558ce85c-4cb4-8e56-6041-fc4bce2ee27f@suse.cz>
 <alpine.DEB.2.10.1701061407300.138109@chino.kir.corp.google.com>
 <baeae644-30c4-5f99-2f99-6042766d7885@suse.cz>
 <alpine.DEB.2.10.1701091818340.61862@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1701091818340.61862@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 09-01-17 18:19:56, David Rientjes wrote:
> On Mon, 9 Jan 2017, Vlastimil Babka wrote:
> 
> > > Any suggestions for a better name for "background" are more than welcome.  
> > 
> > Why not just "madvise+defer"?
> > 
> 
> Seeing no other activity regarding this issue (omg!), I'll wait a day or 
> so to see if there are any objections to "madvise+defer" or suggestions 
> that may be better and repost.

madvise+defer is much better than background. So if the combined (flag
like approach) is too risky then I am OK with that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
